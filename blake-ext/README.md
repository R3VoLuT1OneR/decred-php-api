# PHP BLAKE (Zephir Extension)
BLAKE hashing algorithm implementation (PHP Extension)

Please read more about Zephir language [https://zephir-lang.com/](https://zephir-lang.com/)

# Installation
You should be in folder of this file and run `zephir install`.
Zephir will compile extension and install extension (root password needed).
Add `blake.so` file to `php.ini` and restart HTTP server.

# Usage
```
\Blake\Hash::blake256('') === "716f6e863f744b9ac22c97ec7b76ea5f5908bc5b2f67c61510bfc4751384ea7a"
```
