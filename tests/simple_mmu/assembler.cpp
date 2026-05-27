// mmu_assembler.cpp
// C++17 assembler for the MMU ISA described in the project report
// Produces 25-bit binary instructions, one per line, ready for instruction_file.txt
//
// Usage:
//   g++ -std=c++17 -O2 mmu_assembler.cpp -o mmu_assembler
//   ./mmu_assembler input.asm instruction_file.txt
//
// Notes:
// - Registers: r0 .. r31
// - Immediates: decimal (123), hex (0x7B or #0x7B)
// - Bit field positions are configurable at the top of the file

#include <bits/stdc++.h>
using namespace std;
using u32 = uint32_t;
using i64 = long long;

// ========== CONFIGURABLE BIT FIELD LAYOUT ==========
// Instruction: 25 bits [24 downto 0] (MSB first)
// These field positions match the VHDL decoder.vhd implementation
// If your decoder uses different positions, adjust the constants below.

constexpr int INSTR_WIDTH = 25;

// Common positions
constexpr int TYPE_MSB = 24;
constexpr int TYPE_LSB = 23;  // 2 bits for instruction type

// LDI format (type "00" or "01"):
// [24:23] type (00 or 01)
// [22:20] index (3 bits) - opcode(2 downto 0) in load_immediate.vhd
// [20:5]  immediate (16 bits) - instruction(20 downto 5) in decoder.vhd
// [4:0]   rd (5 bits) - instruction(4 downto 0) in decoder.vhd
struct Field {
    int msb, lsb;
};
static Field fld_ldi_index  {23, 21};
static Field fld_ldi_immed  {20, 5};   // Fixed: was {19, 4}, now {20, 5} to match decoder
static Field fld_ldi_rd     {4, 0};

// R4 format (type "10" - saturating math):
// [24:23] type (10)
// [22:20] sub-opcode (3 bits) - opcode(2 downto 0) in saturate_math.vhd
// [19:15] rs3 (5 bits)
// [14:10] rs2 (5 bits)
// [9:5]   rs1 (5 bits)
// [4:0]   rd (5 bits)
static Field fld_r4_subop   {22, 20};
static Field fld_r4_rs3     {19, 15};
static Field fld_r4_rs2     {14, 10};
static Field fld_r4_rs1     {9, 5};
static Field fld_r4_rd      {4, 0};

// RSI format (type "11" - rest instructions):
// [24:23] type (11)
// [18:15] opcode(3 downto 0) - used by rest_instruction.vhd
// [14:10] rs2 (5 bits) - for most instructions
// [9:5]   rs1 (5 bits)
// [4:0]   rd (5 bits)
// Special cases:
//   SHRHI (0001): [14:11] immediate (4 bits), [10:6] rs1, [5:1] rd, [0] unused
//   MLHUC (1010): [14:10] immediate (5 bits), [9:5] rs1, [4:0] rd
static Field fld_rsi_op4    {18, 15};
static Field fld_rsi_rs2    {14, 10};
static Field fld_rsi_rs1    {9, 5};
static Field fld_rsi_rd     {4, 0};

// Special immediate fields for SHRHI and MLHUC
// SHRHI: immediate in bits [13:10], rs1 in [9:5], rd in [4:0]
static Field fld_shrhi_imm  {13, 10};  // 4 bits
static Field fld_shrhi_rs1  {9, 5};    // 5 bits
static Field fld_shrhi_rd   {4, 0};    // 5 bits
// MLHUC: immediate in bits [14:10], rs1 in [9:5], rd in [4:0]
static Field fld_mlhuc_imm  {14, 10};  // 5 bits

// Helper to write a value into a bitfield within a 32-bit word
inline void set_field(u32 &word, Field f, u32 value) {
    int width = f.msb - f.lsb + 1;
    u32 mask = ((1u << width) - 1u);
    value &= mask;
    word |= (value << f.lsb);
}

// ========== ISA ENCODERS ==========

struct EncResult { bool ok; u32 instr; string err; };
using EncFn = function<EncResult(const vector<string>&)>;

map<string, EncFn> encoders;
map<string, string> canonical; // canonical names (case insensitive)

int reg_index(const string& s) {
    // accept r0..r31
    if (s.size() >= 2 && (s[0]=='r' || s[0]=='R')) {
        try {
            int idx = stoi(s.substr(1));
            if (0 <= idx && idx <= 31) return idx;
        } catch(...) {}
    }
    return -1;
}

i64 parse_imm(const string &tok, bool &ok) {
    ok = false;
    string s = tok;
    if (s.size() > 0 && s[0] == '#') s = s.substr(1);
    // hex?
    if (s.rfind("0x", 0) == 0 || s.rfind("0X", 0) == 0) {
        try {
            i64 v = stoll(s, nullptr, 16);
            ok = true; return v;
        } catch(...) { ok = false; return 0; }
    }
    // decimal
    try {
        i64 v = stoll(s, nullptr, 0);
        ok = true; return v;
    } catch(...) { ok = false; return 0; }
}

// Convenience: make 2-bit type in top bits
inline void set_type(u32 &w, int type2) {
    set_field(w, Field{TYPE_MSB, TYPE_LSB}, (u32)type2);
}

// ========== ENCODER FUNCTIONS ==========

// R4 family: mapped to type "10" (binary 2)
void add_r4(const string &mnem, int subop3) {
    canonical[mnem] = mnem;
    encoders[mnem] = [subop3](const vector<string>& ops)->EncResult {
        // expect: rs3, rs2, rs1, rd
        if (ops.size() != 4) return {false, 0, "R4 instructions require 4 operands: rs3, rs2, rs1, rd"};
        int rs3 = reg_index(ops[0]); if (rs3 < 0) return {false, 0, "bad reg: " + ops[0]};
        int rs2 = reg_index(ops[1]); if (rs2 < 0) return {false, 0, "bad reg: " + ops[1]};
        int rs1 = reg_index(ops[2]); if (rs1 < 0) return {false, 0, "bad reg: " + ops[2]};
        int rd  = reg_index(ops[3]); if (rd < 0)  return {false, 0, "bad reg: " + ops[3]};
        u32 w = 0;
        set_type(w, 2); // '10'
        set_field(w, fld_r4_subop, (u32)subop3);
        set_field(w, fld_r4_rs3, rs3);
        set_field(w, fld_r4_rs2, rs2);
        set_field(w, fld_r4_rs1, rs1);
        set_field(w, fld_r4_rd,  rd);
        return {true, w, ""};
    };
}

// RSI family: type "11" (binary 3). Most use rs2, rs1, rd
void add_rsi_rs2_rs1_rd(const string &mnem, int op4) {
    canonical[mnem] = mnem;
    encoders[mnem] = [op4](const vector<string>& ops)->EncResult {
        if (ops.size() != 3) return {false, 0, "RSI (rs2, rs1, rd) need 3 operands: rs2, rs1, rd"};
        int rs2 = reg_index(ops[0]); if (rs2 < 0) return {false, 0, "bad reg: " + ops[0]};
        int rs1 = reg_index(ops[1]); if (rs1 < 0) return {false, 0, "bad reg: " + ops[1]};
        int rd  = reg_index(ops[2]); if (rd < 0)  return {false, 0, "bad reg: " + ops[2]};
        u32 w = 0;
        set_type(w, 3); // '11'
        set_field(w, fld_rsi_op4, (u32)op4);
        set_field(w, fld_rsi_rs2, rs2);
        set_field(w, fld_rsi_rs1, rs1);
        set_field(w, fld_rsi_rd,  rd);
        return {true, w, ""};
    };
}

// SHRHI: special format with immediate in rs2 position
void add_shrhi(const string &mnem, int op4) {
    canonical[mnem] = mnem;
    encoders[mnem] = [op4](const vector<string>& ops)->EncResult {
        // format: immediate(4 bits), rs1, rd
        if (ops.size() != 3) return {false, 0, "SHRHI format: immediate, rs1, rd"};
        bool ok; i64 imm = parse_imm(ops[0], ok);
        if (!ok || imm < 0 || imm > 15) return {false, 0, "SHRHI immediate must be 0..15"};
        int rs1 = reg_index(ops[1]); if (rs1 < 0) return {false, 0, "bad reg: " + ops[1]};
        int rd  = reg_index(ops[2]); if (rd < 0)  return {false, 0, "bad reg: " + ops[2]};
        u32 w = 0;
        set_type(w, 3); // '11'
        set_field(w, fld_rsi_op4, (u32)op4);
        set_field(w, fld_shrhi_imm, (u32)imm);
        set_field(w, fld_shrhi_rs1, rs1);
        set_field(w, fld_shrhi_rd,  rd);
        return {true, w, ""};
    };
}

// MLHUC: special format with immediate in rs2 position
void add_mlhuc(const string &mnem, int op4) {
    canonical[mnem] = mnem;
    encoders[mnem] = [op4](const vector<string>& ops)->EncResult {
        // format: immediate(5 bits), rs1, rd
        if (ops.size() != 3) return {false, 0, "MLHUC format: immediate, rs1, rd"};
        bool ok; i64 imm = parse_imm(ops[0], ok);
        if (!ok || imm < 0 || imm > 31) return {false, 0, "MLHUC immediate must be 0..31"};
        int rs1 = reg_index(ops[1]); if (rs1 < 0) return {false, 0, "bad reg: " + ops[1]};
        int rd  = reg_index(ops[2]); if (rd < 0)  return {false, 0, "bad reg: " + ops[2]};
        u32 w = 0;
        set_type(w, 3); // '11'
        set_field(w, fld_rsi_op4, (u32)op4);
        set_field(w, fld_mlhuc_imm, (u32)imm);
        set_field(w, fld_rsi_rs1, rs1);
        set_field(w, fld_rsi_rd,  rd);
        return {true, w, ""};
    };
}

// LDI family: type "00" or "01"
void add_ldi(const string &mnem, int type2) {
    canonical[mnem] = mnem;
    encoders[mnem] = [type2](const vector<string>& ops)->EncResult {
        // Expect: rd, index(0..7), immediate16
        if (ops.size() != 3) return {false, 0, "LDI format: rd, index(0..7), immediate16"};
        int rd = reg_index(ops[0]); if (rd < 0) return {false, 0, "bad rd: " + ops[0]};
        bool ok; i64 idx = parse_imm(ops[1], ok);
        if (!ok || idx < 0 || idx > 7) return {false, 0, "index must be 0..7"};
        bool ok2; i64 imm = parse_imm(ops[2], ok2);
        if (!ok2 || imm < 0 || imm > 0xFFFF) return {false, 0, "immediate must be 0..0xFFFF"};
        u32 w = 0;
        set_type(w, type2); // 0 or 1
        set_field(w, fld_ldi_index, (u32)idx);
        set_field(w, fld_ldi_immed, (u32)imm);
        set_field(w, fld_ldi_rd, (u32)rd);
        return {true, w, ""};
    };
}

// NOP
void add_nop() {
    canonical["NOP"] = "NOP";
    encoders["NOP"] = [](const vector<string>&)->EncResult {
        u32 w = 0;
        set_type(w, 3); // type 11
        set_field(w, fld_rsi_op4, 0); // opcode 0000
        return {true, w, ""};
    };
}

// ========== INITIALIZE ENCODER TABLE ==========

void init_encoders() {
    // R4 saturating family (type 10) - subop values from saturate_math.vhd
    add_r4("SIMAL", 0b000);  // Saturated Signed Integer Multiply-Add Low
    add_r4("SIMAH", 0b001);  // High
    add_r4("SIMSL", 0b010);  // Multiply-Subtract Low
    add_r4("SIMSH", 0b011);  // Multiply-Subtract High
    add_r4("SLMAL", 0b100);  // Saturated Long Multiply-Add Low
    add_r4("SLMAH", 0b101);  // High
    add_r4("SLMSL", 0b110);  // Multiply-Subtract Low
    add_r4("SLMSH", 0b111);  // Multiply-Subtract High

    // RSI family (type 11) - opcodes from rest_instruction.vhd
    add_shrhi("SHRHI", 0b0001);  // shift right halfword immediate (special format)
    add_rsi_rs2_rs1_rd("AU",     0b0010);  // add word unsigned
    add_rsi_rs2_rs1_rd("CNT1H",  0b0011);  // count 1s in halfword
    add_rsi_rs2_rs1_rd("AHS",    0b0100);  // add halfword saturated
    add_rsi_rs2_rs1_rd("OR",     0b0101);  // bitwise logical or
    add_rsi_rs2_rs1_rd("BCW",    0b0110);  // broadcast word
    add_rsi_rs2_rs1_rd("MAXWS",  0b0111);  // max signed word
    add_rsi_rs2_rs1_rd("MINWS",  0b1000);  // min signed word
    add_rsi_rs2_rs1_rd("MLHU",   0b1001);  // multiply low unsigned
    add_mlhuc("MLHUC", 0b1010);  // multiply low by constant unsigned (special format)
    add_rsi_rs2_rs1_rd("AND",    0b1011);  // bitwise logical and
    add_rsi_rs2_rs1_rd("CLZW",   0b1100);  // count leading zeroes in words
    add_rsi_rs2_rs1_rd("ROTW",   0b1101);  // rotate bits in word
    add_rsi_rs2_rs1_rd("SFWU",   0b1110);  // subtract from word unsigned
    add_rsi_rs2_rs1_rd("SFHS",   0b1111);  // subtract from halfword saturated

    // LDI family (type 00)
    add_ldi("LDI", 0);

    // NOP
    add_nop();

    // Add lowercase variants
    vector<string> keys;
    for (auto &kv : encoders) keys.push_back(kv.first);
    for (auto &k : keys) {
        string lower = k;
        for (auto &c : lower) c = tolower((unsigned char)c);
        canonical[lower] = k;
    }
}

// ========== ASSEMBLY PARSING ==========

static inline string trim(const string &s) {
    size_t a = s.find_first_not_of(" \t\r\n");
    if (a == string::npos) return "";
    size_t b = s.find_last_not_of(" \t\r\n");
    return s.substr(a, b - a + 1);
}

vector<string> split_operands(const string &s) {
    vector<string> res;
    string cur;
    for (size_t i = 0; i < s.size(); ++i) {
        char c = s[i];
        if (c == ',') {
            string tok = trim(cur);
            if (!tok.empty()) res.push_back(tok);
            cur.clear();
        } else {
            cur.push_back(c);
        }
    }
    string tok = trim(cur);
    if (!tok.empty()) res.push_back(tok);
    return res;
}

string to_upper(string s) {
    for (auto &c : s) c = toupper((unsigned char)c);
    return s;
}

struct Line {
    int lineno;
    string mnemonic;
    vector<string> ops;
    string raw;
};

int main(int argc, char** argv) {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    if (argc < 3) {
        cerr << "Usage: mmu_assembler input.asm output.txt\n";
        return 1;
    }
    string infile = argv[1];
    string outfile = argv[2];

    init_encoders();

    ifstream ifs(infile);
    if (!ifs) {
        cerr << "Cannot open " << infile << "\n";
        return 1;
    }

    vector<Line> program;
    string line;
    int lineno = 0;
    
    // Parse lines
    while (getline(ifs, line)) {
        ++lineno;
        string s = trim(line);
        if (s.empty()) continue;
        
        // skip comments (// or ;)
        size_t cpos = s.find("//");
        if (cpos != string::npos) s = trim(s.substr(0, cpos));
        cpos = s.find(';');
        if (cpos != string::npos) s = trim(s.substr(0, cpos));
        if (s.empty()) continue;

        // skip label-only lines (labels not supported yet)
        size_t colon = s.find(':');
        if (colon != string::npos) {
            string rest = trim(s.substr(colon + 1));
            if (rest.empty()) continue; // label-only line, skip it
            s = rest; // use text after label
        }

        // parse mnemonic and operands
        stringstream ss(s);
        string mnem;
        ss >> mnem;
        string rest_ops;
        getline(ss, rest_ops);
        rest_ops = trim(rest_ops);
        vector<string> ops = split_operands(rest_ops);
        
        Line L;
        L.lineno = lineno;
        L.mnemonic = mnem;
        L.ops = ops;
        L.raw = line;
        
        program.push_back(L);
    }

    // Pass 2: assemble each line
    vector<string> out_lines;
    for (size_t i = 0; i < program.size(); ++i) {
        Line &L = program[i];
        if (L.mnemonic.empty()) continue;
        
        string m = to_upper(L.mnemonic);
        string key = m;
        
        // Check canonical mapping (for case-insensitive lookup)
        if (canonical.find(key) != canonical.end()) {
            key = canonical[key];
        }
        
        if (encoders.find(key) == encoders.end()) {
            cerr << "Line " << L.lineno << ": unknown mnemonic '" << L.mnemonic << "'\n";
            return 2;
        }
        
        // encode
        EncResult er = encoders[key](L.ops);
        if (!er.ok) {
            cerr << "Line " << L.lineno << ": encode error: " << er.err << "\n";
            return 3;
        }
        
        u32 instr = er.instr & ((1u << INSTR_WIDTH) - 1);
        
        // convert to 25-bit binary string MSB first
        string bin;
        for (int b = INSTR_WIDTH - 1; b >= 0; --b) {
            bin.push_back(((instr >> b) & 1) ? '1' : '0');
        }
        out_lines.push_back(bin);
    }

    ofstream ofs(outfile);
    if (!ofs) {
        cerr << "Cannot open " << outfile << " for writing\n";
        return 4;
    }
    for (auto &l : out_lines) ofs << l << "\n";
    ofs.close();
    
    cout << "Assembled " << out_lines.size() << " instructions to " << outfile << "\n";
    return 0;
}

