namespace Blake;

class State256 extends StateAbstract
{

  public h = [];

  private s;

  private t = [0, 0];

  private buffer;

  private nullt;

  private constant = [
      0x243F6A88, 0x85A308D3, 0x13198A2E, 0x03707344,
      0xA4093822, 0x299F31D0, 0x082EFA98, 0xEC4E6C89,
      0x452821E6, 0x38D01377, 0xBE5466CF, 0x34E90C6C,
      0xC0AC29B7, 0xC97C50DD, 0x3F84D5B5, 0xB5470917
  ];

  public function __construct(array s = null)
  {
    let this->s = is_array(s) && count(s) === 4 ? s : [0, 0, 0, 0];
    let this->nullt = 0;
    let this->buffer = "";
    let this->h = [
        0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A,
        0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19
    ];
  }

  public function update(string data)
  {
    var left = strlen(this->buffer);
    int fill = 64 - left;

    if (left && (strlen(data) >= fill)) {
      let this->t[0] = this->t[0] + 512;
      let this->t[0] = this->t[0] & 0xFFFFFFFF;
      if (this->t[0] == 0) {
        let this->t[1] = this->t[1] + 1;
      }

      this->compress(this->buffer . substr(data, 0, fill));

      let data = substr(data, fill);
      let this->buffer = "";
    }

    while (strlen(data) >= 64) {
      let this->t[0] = this->t[0] + 512;
      if (this->t[0] == 0) {
        let this->t[1] = this->t[1] + 1;
      }

      this->compress(substr(data, 0, 64));

      let data = substr(data, 64);
    }

    if (strlen(data) > 0) {
      let this->buffer = this->buffer . data;
    } else {
      let this->buffer = "";
    }
  }

  public function finalize()
  {
    int buflen = strlen(this->buffer), i;
    string zo = "\x01", oo = "\x81";
    var lo, hi;

    let lo = this->t[0] + (buflen << 3);
    let hi = this->t[1];

    if ( lo < (buflen << 3 )) {
     let hi += 1;
    }

    var hi8 = this->u32to8(hi);
    var lo8 = this->u32to8(lo);
    var msglen = implode("", array_map("chr", [
      hi8[0], hi8[1], hi8[2], hi8[3],
      lo8[0], lo8[1], lo8[2], lo8[3]]
    ));

    if (buflen === 55) {

      this->update(oo);
      let this->t[0] = this->t[0] + 8;

    } else {
      if (buflen < 55) {
        if (!buflen) {
          let this->nullt = 1;
        }

        let this->t[0] = this->t[0] - (440 - (buflen << 3));
        this->update(this->padding(0, 55 - buflen));

      } else {

        let this->t[0] = this->t[0] - (512 - (buflen << 3));
        this->update(this->padding(0, 64 - buflen));
        let this->t[0] = this->t[0] - 440;
        this->update(this->padding(1, 55));
        let this->nullt = 1;

      }

      this->update(zo);
      let this->t[0] = this->t[0] - 8;
    }

    let this->t[0] = this->t[0] - 64;
    this->update(msglen);

    string out = "";
    for i in range(0, 7) {
      let out = out . this->u32to8s(this->h[i]);
    }

    return out;
  }

  private function compress(string data)
  {
    array m = [];
    int i;

    for i in range(0, 15) {
      int m1 = data[i*4];
      int m2 = data[(i*4)+1];
      int m3 = data[(i*4)+2];
      int m4 = data[(i*4)+3];
      let m[i] = this->u8to32([m1, m2, m3, m4]);
    }

    array v = [
      this->h[0], this->h[1], this->h[2], this->h[3],
      this->h[4], this->h[5], this->h[6], this->h[7],
      this->s[0] ^ this->constant[0],
      this->s[1] ^ this->constant[1],
      this->s[2] ^ this->constant[2],
      this->s[3] ^ this->constant[3],
      this->constant[4],
      this->constant[5],
      this->constant[6],
      this->constant[7]
    ];

    if (!this->nullt) {
      let v[12] = v[12] ^ this->t[0];
      let v[13] = v[13] ^ this->t[0];
      let v[14] = v[14] ^ this->t[1];
      let v[15] = v[15] ^ this->t[1];
    }

    for i in range(0, 13) {
      let v = this->g(v,  0,  4,  8,  12,   0, m, i);
      let v = this->g(v,  1,  5,  9,  13,   2, m, i);
      let v = this->g(v,  2,  6, 10,  14,   4, m, i);
      let v = this->g(v,  3,  7, 11,  15,   6, m, i);

      let v = this->g(v,  0,  5, 10,  15,   8, m, i);
      let v = this->g(v,  1,  6, 11,  12,  10, m, i);
      let v = this->g(v,  2,  7,  8,  13,  12, m, i);
      let v = this->g(v,  3,  4,  9,  14,  14, m, i);
    }

    for i in range(0, 15) {
      int ix = i % 8;
      let this->h[ix] = this->h[ix] ^ v[i];
    }
    for i in range(0, 7) {
      int ix = i % 4;
      let this->h[ix] = this->h[ix] ^ this->s[ix];
    }
  }
}
