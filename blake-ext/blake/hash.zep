namespace Blake;

class Hash
{
  public static function blake256(string! data)
  {
    var state;
    let state = new State256();
    state->update(data);
    return state->finalize();
  }
}
