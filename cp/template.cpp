// GPT Generated Template lol
#include <bits/stdc++.h>
using namespace std;

// Typedefs / Aliases
using ll  = long long;
using ull = unsigned long long;
using pii = pair<int,int>;
using pll = pair<ll,ll>;
using vi  = vector<int>;
using vll = vector<ll>;
using ld  = long double;

static constexpr int MOD = 1'000'000'007;
static constexpr int INF = 1e9;
static constexpr ll  LINF = (ll)4e18;

// RNG
mt19937_64 rng((uint64_t)chrono::steady_clock::now().time_since_epoch().count());

// Utility Functions
template <class T>
bool chmin(T &a, const T &b) { return (b < a) ? (a = b, true) : false; }

template <class T>
bool chmax(T &a, const T &b) { return (b > a) ? (a = b, true) : false; }

ll modpow(ll a, ll e, ll mod = MOD) {
    ll r = 1 % mod;
    a %= mod;
    while (e > 0) {
        if (e & 1) r = (r * a) % mod;
        a = (a * a) % mod;
        e >>= 1;
    }
    return r;
}

// MOD must be prime for this inverse
ll modinv(ll a, ll mod = MOD) {
    return modpow(a, mod - 2, mod);
}

ll gcdll(ll a, ll b) { return std::gcd(a, b); }
ll lcmll(ll a, ll b) { return a / std::gcd(a, b) * b; }

// Modular Integer
struct Mint {
    int v;

    Mint(long long _v = 0) {
        if (_v < 0) _v = _v % MOD + MOD;
        if (_v >= MOD) _v %= MOD;
        v = (int)_v;
    }

    Mint& operator+=(const Mint& o) {
        v += o.v;
        if (v >= MOD) v -= MOD;
        return *this;
    }
    Mint& operator-=(const Mint& o) {
        v -= o.v;
        if (v < 0) v += MOD;
        return *this;
    }
    Mint& operator*=(const Mint& o) {
        v = (int)((1LL * v * o.v) % MOD);
        return *this;
    }

    friend Mint operator+(Mint a, const Mint& b) { return a += b; }
    friend Mint operator-(Mint a, const Mint& b) { return a -= b; }
    friend Mint operator*(Mint a, const Mint& b) { return a *= b; }

    Mint pow(long long e) const {
        Mint base = *this, res = 1;
        while (e > 0) {
            if (e & 1) res *= base;
            base *= base;
            e >>= 1;
        }
        return res;
    }

    Mint inv() const { return pow(MOD - 2); }

    Mint& operator/=(const Mint& o) { return (*this) *= o.inv(); }
    friend Mint operator/(Mint a, const Mint& b) { return a /= b; }

    explicit operator int() const { return v; }
    explicit operator long long() const { return v; }
};

ostream& operator<<(ostream& os, const Mint& m) {
    return os << m.v;
}
istream& operator>>(istream& is, Mint& m) {
    long long x;
    is >> x;
    m = Mint(x);
    return is;
}

// Fenwick Tree (BIT)
// 1-indexed
template <class T>
struct Fenwick {
    int n;
    vector<T> bit;

    Fenwick(int n = 0) { init(n); }

    void init(int n_) {
        n = n_;
        bit.assign(n + 1, T{});
    }

    void add(int idx, T val) {
        for (; idx <= n; idx += idx & -idx) bit[idx] += val;
    }

    T sumPrefix(int idx) const {
        T res{};
        for (; idx > 0; idx -= idx & -idx) res += bit[idx];
        return res;
    }

    T sumRange(int l, int r) const {
        if (l > r) return T{};
        return sumPrefix(r) - sumPrefix(l - 1);
    }
};

// Segment Tree
// Iterative segment tree with custom merge.
// Good for sum/min/max with an identity element.
template <class T>
struct SegTree {
    int n;
    T id;
    function<T(const T&, const T&)> merge;
    vector<T> st;

    SegTree() {}

    SegTree(int n_, T id_, function<T(const T&, const T&)> merge_)
        : n(n_), id(id_), merge(std::move(merge_)) {
        st.assign(2 * n, id);
    }

    void build(const vector<T>& a) {
        int sz = (int)a.size();
        n = sz;
        st.assign(2 * n, id);
        for (int i = 0; i < n; ++i) st[n + i] = a[i];
        for (int i = n - 1; i > 0; --i) st[i] = merge(st[i << 1], st[i << 1 | 1]);
    }

    // set a[p] = val
    void setval(int p, T val) {
        for (st[p += n] = val; p > 1; p >>= 1)
            st[p >> 1] = merge(st[p], st[p ^ 1]);
    }

    // query on [l, r)
    T query(int l, int r) const {
        T left = id, right = id;
        for (l += n, r += n; l < r; l >>= 1, r >>= 1) {
            if (l & 1) left = merge(left, st[l++]);
            if (r & 1) right = merge(st[--r], right);
        }
        return merge(left, right);
    }
};

// DSU / Union Find
struct DSU {
    int n;
    vector<int> p, sz;

    DSU(int n = 0) { init(n); }

    void init(int n_) {
        n = n_;
        p.resize(n + 1);
        sz.assign(n + 1, 1);
        iota(p.begin(), p.end(), 0);
    }

    int find(int x) {
        return p[x] == x ? x : p[x] = find(p[x]);
    }

    bool unite(int a, int b) {
        a = find(a); b = find(b);
        if (a == b) return false;
        if (sz[a] < sz[b]) swap(a, b);
        p[b] = a;
        sz[a] += sz[b];
        return true;
    }

    int size(int x) { return sz[find(x)]; }
};

// Graph Helpers
using Graph = vector<vector<int>>;

void addEdge(Graph& g, int u, int v, bool undirected = true) {
    g[u].push_back(v);
    if (undirected) g[v].push_back(u);
}

// Prime Sieve
vector<int> primes, spf;

void linear_sieve(int n) {
    spf.assign(n + 1, 0);
    primes.clear();
    for (int i = 2; i <= n; ++i) {
        if (spf[i] == 0) {
            spf[i] = i;
            primes.push_back(i);
        }
        for (int p : primes) {
            if (p > spf[i] || 1LL * p * i > n) break;
            spf[p * i] = p;
        }
    }
}

// Debug Helpers
#ifdef LOCAL
template<class T>
void debug_print(const T& x) { cerr << x; }

template<class T, class... Ts>
void debug_print(const T& x, const Ts&... xs) {
    cerr << x << ' ';
    debug_print(xs...);
}

#define dbg(...) do { cerr << "[ " << #__VA_ARGS__ << " ] = "; debug_print(__VA_ARGS__); cerr << '\n'; } while (0)
#else
#define dbg(...) ((void)0)
#endif

void solve() {
  
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int T = 1;
    cin >> T;
    while (T--) solve();
    return 0;
}
