// mmu_assembler.cpp - MMU ISA → 25-bit binary
// Usage: g++ -std=c++17 -O2 mmu_assembler.cpp -o mmu_assembler && ./mmu_assembler input.asm output.txt

#include <bits/stdc++.h>
using namespace std;
using u32 = uint32_t;
using i64 = long long;

constexpr int INSTR_WIDTH = 25, TYPE_MSB = 24, TYPE_LSB = 23;

struct Field { int msb, lsb; };
static Field fld_ldi_index{23, 21}, fld_ldi_immed{20, 5}, fld_ldi_rd{4, 0};
static Field fld_r4_subop{22, 20}, fld_r4_rs3{19, 15}, fld_r4_rs2{14, 10}, fld_r4_rs1{9, 5}, fld_r4_rd{4, 0};
static Field fld_rsi_op4{18, 15}, fld_rsi_rs2{14, 10}, fld_rsi_rs1{9, 5}, fld_rsi_rd{4, 0};
static Field fld_shrhi_imm{13, 10}, fld_shrhi_rs1{9, 5}, fld_shrhi_rd{4, 0}, fld_mlhuc_imm{14, 10};
static Field fld_branch_subop{22, 19}, fld_branch_imm{18, 10}, fld_branch_rs2{9, 5}, fld_branch_rs1{4, 0};

inline void set_field(u32& w, Field f, u32 v) { w |= ((v & ((1u << (f.msb - f.lsb + 1)) - 1u)) << f.lsb); }
inline void set_type(u32& w, int t) { set_field(w, Field{TYPE_MSB, TYPE_LSB}, (u32)t); }

struct EncResult { bool ok; u32 instr; string err; };
using EncFn = function<EncResult(const vector<string>&)>;
map<string, EncFn> encoders;
map<string, string> canonical;

int reg_index(const string& s) {
    if (s.size() < 2 || (s[0] != 'r' && s[0] != 'R')) return -1;
    try { int idx = stoi(s.substr(1)); return (0 <= idx && idx <= 31) ? idx : -1; } catch (...) { return -1; }
}

i64 parse_imm(const string& tok, bool& ok) {
    ok = false;
    string s = tok;
    if (!s.empty() && s[0] == '#') s = s.substr(1);
    if (s.rfind("0x", 0) == 0 || s.rfind("0X", 0) == 0) {
        try { i64 v = stoll(s, nullptr, 16); ok = true; return v; } catch (...) { return 0; }
    }
    try { i64 v = stoll(s, nullptr, 0); ok = true; return v; } catch (...) { return 0; }
}

void add_r4(const string& mnem, int subop3) {
    canonical[mnem] = mnem;
    encoders[mnem] = [subop3](const vector<string>& ops) -> EncResult {
        if (ops.size() != 4) return {false, 0, "R4: rs3, rs2, rs1, rd"};
        int rs3 = reg_index(ops[0]), rs2 = reg_index(ops[1]), rs1 = reg_index(ops[2]), rd = reg_index(ops[3]);
        if (rs3 < 0 || rs2 < 0 || rs1 < 0 || rd < 0) return {false, 0, "bad reg"};
        u32 w = 0; set_type(w, 2);
        set_field(w, fld_r4_subop, (u32)subop3); set_field(w, fld_r4_rs3, rs3);
        set_field(w, fld_r4_rs2, rs2); set_field(w, fld_r4_rs1, rs1); set_field(w, fld_r4_rd, rd);
        return {true, w, ""};
    };
}

void add_rsi_rs2_rs1_rd(const string& mnem, int op4) {
    canonical[mnem] = mnem;
    encoders[mnem] = [op4](const vector<string>& ops) -> EncResult {
        if (ops.size() != 3) return {false, 0, "RSI: rs2, rs1, rd"};
        int rs2 = reg_index(ops[0]), rs1 = reg_index(ops[1]), rd = reg_index(ops[2]);
        if (rs2 < 0 || rs1 < 0 || rd < 0) return {false, 0, "bad reg"};
        u32 w = 0; set_type(w, 3);
        set_field(w, fld_rsi_op4, (u32)op4); set_field(w, fld_rsi_rs2, rs2);
        set_field(w, fld_rsi_rs1, rs1); set_field(w, fld_rsi_rd, rd);
        return {true, w, ""};
    };
}

void add_shrhi(const string& mnem, int op4) {
    canonical[mnem] = mnem;
    encoders[mnem] = [op4](const vector<string>& ops) -> EncResult {
        if (ops.size() != 3) return {false, 0, "SHRHI: imm, rs1, rd"};
        bool ok; i64 imm = parse_imm(ops[0], ok);
        if (!ok || imm < 0 || imm > 15) return {false, 0, "SHRHI imm 0..15"};
        int rs1 = reg_index(ops[1]), rd = reg_index(ops[2]);
        if (rs1 < 0 || rd < 0) return {false, 0, "bad reg"};
        u32 w = 0; set_type(w, 3);
        set_field(w, fld_rsi_op4, (u32)op4); set_field(w, fld_shrhi_imm, (u32)imm);
        set_field(w, fld_shrhi_rs1, rs1); set_field(w, fld_shrhi_rd, rd);
        return {true, w, ""};
    };
}

void add_mlhuc(const string& mnem, int op4) {
    canonical[mnem] = mnem;
    encoders[mnem] = [op4](const vector<string>& ops) -> EncResult {
        if (ops.size() != 3) return {false, 0, "MLHUC: imm, rs1, rd"};
        bool ok; i64 imm = parse_imm(ops[0], ok);
        if (!ok || imm < 0 || imm > 31) return {false, 0, "MLHUC imm 0..31"};
        int rs1 = reg_index(ops[1]), rd = reg_index(ops[2]);
        if (rs1 < 0 || rd < 0) return {false, 0, "bad reg"};
        u32 w = 0; set_type(w, 3);
        set_field(w, fld_rsi_op4, (u32)op4); set_field(w, fld_mlhuc_imm, (u32)imm);
        set_field(w, fld_rsi_rs1, rs1); set_field(w, fld_rsi_rd, rd);
        return {true, w, ""};
    };
}

void add_ldi(const string& mnem, int type2) {
    canonical[mnem] = mnem;
    encoders[mnem] = [type2](const vector<string>& ops) -> EncResult {
        if (ops.size() != 3) return {false, 0, "LDI: rd, index(0..7), imm"};
        int rd = reg_index(ops[0]); if (rd < 0) return {false, 0, "bad rd"};
        bool ok; i64 idx = parse_imm(ops[1], ok);
        if (!ok || idx < 0 || idx > 7) return {false, 0, "LDI index 0..7"};
        bool ok2; i64 imm = parse_imm(ops[2], ok2);
        if (!ok2 || imm < 0 || imm > 0xFFFF) return {false, 0, "LDI imm 0..0xFFFF"};
        u32 w = 0; set_type(w, type2);
        set_field(w, fld_ldi_index, (u32)idx); set_field(w, fld_ldi_immed, (u32)imm); set_field(w, fld_ldi_rd, (u32)rd);
        return {true, w, ""};
    };
}

void add_nop() {
    canonical["NOP"] = "NOP";
    encoders["NOP"] = [](const vector<string>&) -> EncResult {
        u32 w = 0; set_type(w, 3); set_field(w, fld_rsi_op4, 0); return {true, w, ""};
    };
}

void init_encoders() {
    add_r4("SIMAL", 0b000); add_r4("SIMAH", 0b001); add_r4("SIMSL", 0b010); add_r4("SIMSH", 0b011);
    add_r4("SLMAL", 0b100); add_r4("SLMAH", 0b101); add_r4("SLMSL", 0b110); add_r4("SLMSH", 0b111);
    add_shrhi("SHRHI", 0b0001);
    add_rsi_rs2_rs1_rd("AU", 0b0010); add_rsi_rs2_rs1_rd("CNT1H", 0b0011); add_rsi_rs2_rs1_rd("AHS", 0b0100);
    add_rsi_rs2_rs1_rd("OR", 0b0101); add_rsi_rs2_rs1_rd("BCW", 0b0110); add_rsi_rs2_rs1_rd("MAXWS", 0b0111);
    add_rsi_rs2_rs1_rd("MINWS", 0b1000); add_rsi_rs2_rs1_rd("MLHU", 0b1001);
    add_mlhuc("MLHUC", 0b1010);
    add_rsi_rs2_rs1_rd("AND", 0b1011); add_rsi_rs2_rs1_rd("CLZW", 0b1100); add_rsi_rs2_rs1_rd("ROTW", 0b1101);
    add_rsi_rs2_rs1_rd("SFWU", 0b1110); add_rsi_rs2_rs1_rd("SFHS", 0b1111);
    add_ldi("LDI", 0); add_nop();
    for (auto& kv : encoders) {
        string lower = kv.first;
        for (auto& c : lower) c = tolower((unsigned char)c);
        canonical[lower] = kv.first;
    }
}

string trim(const string& s) {
    size_t a = s.find_first_not_of(" \t\r\n");
    return (a == string::npos) ? "" : s.substr(a, s.find_last_not_of(" \t\r\n") - a + 1);
}

vector<string> split_operands(const string& s) {
    vector<string> res;
    string cur;
    for (char c : s) {
        if (c == ',') {
            string tok = trim(cur);
            if (!tok.empty()) res.push_back(tok);
            cur.clear();
        } else cur.push_back(c);
    }
    string tok = trim(cur);
    if (!tok.empty()) res.push_back(tok);
    return res;
}

string to_upper(string s) {
    for (auto& c : s) c = toupper((unsigned char)c);
    return s;
}

struct Line { int lineno; string label; string mnemonic; vector<string> ops; string raw; };

int main(int argc, char** argv) {
    ios::sync_with_stdio(false); cin.tie(nullptr);
    if (argc < 3) { cerr << "Usage: mmu_assembler input.asm output.txt\n"; return 1; }
    init_encoders();
    ifstream ifs(argv[1]);
    if (!ifs) { cerr << "Cannot open " << argv[1] << "\n"; return 1; }

    vector<Line> program;
    string line;
    for (int lineno = 1; getline(ifs, line); ++lineno) {
        string s = trim(line);
        if (s.empty()) continue;
        size_t cpos = s.find("//");
        if (cpos != string::npos) s = trim(s.substr(0, cpos));
        cpos = s.find(';');
        if (cpos != string::npos) s = trim(s.substr(0, cpos));
        if (s.empty()) continue;
        string label;
        size_t colon = s.find(':');
        if (colon != string::npos) {
            label = trim(s.substr(0, colon));
            s = trim(s.substr(colon + 1));
        }
        string mnemonic;
        vector<string> ops;
        if (!s.empty()) {
            stringstream ss(s);
            ss >> mnemonic;
            string rest_ops; getline(ss, rest_ops);
            ops = split_operands(trim(rest_ops));
        }
        program.push_back({lineno, label, mnemonic, ops, line});
    }

    map<string, int> labels;
    int pc = 0;
    for (auto& L : program) {
        if (!L.label.empty()) {
            if (labels.count(L.label)) { cerr << "Line " << L.lineno << ": duplicate label '" << L.label << "'\n"; return 5; }
            labels[L.label] = pc;
        }
        if (!L.mnemonic.empty()) pc++;
    }

    vector<string> out_lines;
    int current_pc = 0;
    for (const auto& L : program) {
        if (L.mnemonic.empty()) continue;
        string m = to_upper(L.mnemonic);
        string key = (canonical.count(m) ? canonical[m] : m);
        EncResult er;
        if (key == "BEQ" || key == "BNEQ" || key == "BGT" || key == "BLT") {
            if (L.ops.size() != 3) { cerr << "Line " << L.lineno << ": BRANCH rs2, rs1, imm\n"; return 3; }
            int rs2 = reg_index(L.ops[0]), rs1 = reg_index(L.ops[1]);
            if (rs2 < 0 || rs1 < 0) { cerr << "Line " << L.lineno << ": bad reg\n"; return 3; }
            string imm_str = L.ops[2];
            bool ok; i64 imm_val = parse_imm(imm_str, ok);
            if (!ok) {
                if (labels.count(imm_str) == 0) { cerr << "Line " << L.lineno << ": unknown label '" << imm_str << "'\n"; return 3; }
                imm_val = labels[imm_str] - current_pc;
            }
            if (imm_val < -256 || imm_val > 255) { cerr << "Line " << L.lineno << ": imm9 out of range\n"; return 3; }
            u32 w = 0; set_type(w, 3);
            int subop = (key == "BEQ") ? 8 : (key == "BNEQ") ? 9 : (key == "BGT") ? 10 : 11;
            set_field(w, fld_branch_subop, (u32)subop); set_field(w, fld_branch_imm, (u32)(imm_val & 0x1FF));
            set_field(w, fld_branch_rs2, rs2); set_field(w, fld_branch_rs1, rs1);
            er = {true, w, ""};
        } else if (key == "JMP") {
            if (L.ops.size() != 1) { cerr << "Line " << L.lineno << ": JMP imm\n"; return 3; }
            string imm_str = L.ops[0];
            bool ok; i64 imm_val = parse_imm(imm_str, ok);
            if (!ok) {
                if (labels.count(imm_str) == 0) { cerr << "Line " << L.lineno << ": unknown label '" << imm_str << "'\n"; return 3; }
                imm_val = labels[imm_str] - current_pc;
            }
            if (imm_val < -256 || imm_val > 255) { cerr << "Line " << L.lineno << ": imm9 out of range\n"; return 3; }
            u32 w = 0; set_type(w, 3);
            set_field(w, fld_branch_subop, 12); set_field(w, fld_branch_imm, (u32)(imm_val & 0x1FF));
            er = {true, w, ""};
        } else {
            if (!encoders.count(key)) { cerr << "Line " << L.lineno << ": unknown '" << L.mnemonic << "'\n"; return 2; }
            er = encoders[key](L.ops);
        }
        if (!er.ok) { cerr << "Line " << L.lineno << ": " << er.err << "\n"; return 3; }
        u32 instr = er.instr & ((1u << INSTR_WIDTH) - 1);
        string bin;
        for (int b = INSTR_WIDTH - 1; b >= 0; --b) bin.push_back(((instr >> b) & 1) ? '1' : '0');
        out_lines.push_back(bin);
        current_pc++;
    }

    ofstream ofs(argv[2]);
    if (!ofs) { cerr << "Cannot open " << argv[2] << " for writing\n"; return 4; }
    for (auto& l : out_lines) ofs << l << "\n";
    cout << "Assembled " << out_lines.size() << " instructions to " << argv[2] << "\n";
    return 0;
}
