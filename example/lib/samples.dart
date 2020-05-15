import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:flutter_sodium/flutter_sodium.dart';

class Samples {
  final salt = PasswordHash.randomSalt();

  void api1(Function(Object) print) {
    // BEGIN api1: Core API: Compute a password hash using the Core API with predefined salt.
    final pw = utf8.encode('hello world');
    final hash = Sodium.cryptoPwhash(
        Sodium.cryptoPwhashBytesMin,
        pw,
        salt,
        Sodium.cryptoPwhashOpslimitInteractive,
        Sodium.cryptoPwhashMemlimitInteractive,
        Sodium.cryptoPwhashAlgDefault);

    print('salt: ${hex.encode(salt)}');
    print('hash: ${hex.encode(hash)}');
    // END api1
  }

  void api2(Function(Object) print) {
    // BEGIN api2: High-level API: Compute a password hash using the high-level API with predefined salt.
    final pw = 'hello world';
    final hash = PasswordHash.hashString(pw, salt);

    print('salt: ${hex.encode(salt)}');
    print('hash: ${hex.encode(hash)}');
    // END api2
  }

  void random1(Function(Object) print) {
    // BEGIN random1: Random: Returns an unpredictable value between 0 and 0xffffffff (included).
    final rnd = RandomBytes.random();
    print(rnd.toRadixString(16));
    // END random1
  }

  void random2(Function(Object) print) {
    // BEGIN random2: Uniform: Generates an unpredictable value between 0 and upperBound (excluded)
    final rnd = RandomBytes.uniform(16);
    print(rnd);
    // END random2
  }

  void random3(Function(Object) print) {
    // BEGIN random3: Buffer: Generates an unpredictable sequence of bytes of specified size.
    final buf = RandomBytes.buffer(16);
    print(hex.encode(buf));
    // END random3
  }

  void version1(Function(Object) print) {
    // BEGIN version1: Usage: Retrieves the version details of the loaded libsodium library.
    final version = Sodium.sodiumVersionString;
    final major = Sodium.sodiumLibraryVersionMajor;
    final minor = Sodium.sodiumLibraryVersionMinor;

    print('$version ($major.$minor)');
    // END version1
  }

  void version2(Function(Object) print) {
    // BEGIN version2: Primitives: Retrieves the names of the algorithms used in the various libsodium APIs.
    print('crypto_auth: ${Sodium.cryptoAuthPrimitive}');
    print('crypto_box: ${Sodium.cryptoBoxPrimitive}');
    print('crypto_generichash: ${Sodium.cryptoGenerichashPrimitive}');
    print('crypto_kdf: ${Sodium.cryptoKdfPrimitive}');
    print('crypto_kx: ${Sodium.cryptoKxPrimitive}');
    print('crypto_pwhash: ${Sodium.cryptoPwhashPrimitive}');
    print('crypto_scalarmult: ${Sodium.cryptoScalarmultPrimitive}');
    print('crypto_secretbox: ${Sodium.cryptoSecretboxPrimitive}');
    print('crypto_shorthash: ${Sodium.cryptoShorthashPrimitive}');
    print('crypto_sign: ${Sodium.cryptoSignPrimitive}');
    print('randombytes: ${Sodium.randombytesImplementationName}');
    // END version2
  }

  void auth1(Function(Object) print) {
    // BEGIN auth1: Usage: Secret key authentication
    // generate secret
    final key = CryptoAuth.randomKey();

    // compute tag
    final msg = 'hello world';
    final tag = CryptoAuth.computeString(msg, key);
    print(hex.encode(tag));

    // verify tag
    final valid = CryptoAuth.verifyString(tag, msg, key);
    assert(valid);
    // END auth1
  }

  void box1(Function(Object) print) {
    // BEGIN box1: Combined mode: The authentication tag and the encrypted message are stored together.
    // Generate key pairs
    final alice = CryptoBox.randomKeys();
    final bob = CryptoBox.randomKeys();
    final nonce = CryptoBox.randomNonce();

    // Alice encrypts message for Bob
    final msg = 'hello world';
    final encrypted =
        CryptoBox.encryptString(msg, nonce, bob.publicKey, alice.secretKey);

    print(hex.encode(encrypted));

    // Bob decrypts message from Alice
    final decrypted = CryptoBox.decryptString(
        encrypted, nonce, alice.publicKey, bob.secretKey);

    assert(msg == decrypted);
    print('decrypted: $decrypted');
    // END box1
  }

  void box2(Function(Object) print) {
    // BEGIN box2: Detached mode: The authentication tag and the encrypted message are detached so they can be stored at different locations.
    // Generate key pairs
    final alice = CryptoBox.randomKeys();
    final bob = CryptoBox.randomKeys();
    final nonce = CryptoBox.randomNonce();

    // Alice encrypts message for Bob
    final msg = 'hello world';
    final c = CryptoBox.encryptStringDetached(
        msg, nonce, bob.publicKey, alice.secretKey);

    print('cipher: ${hex.encode(c.cipher)}');
    print('mac: ${hex.encode(c.mac)}');

    // Bob decrypts message from Alice
    final decrypted = CryptoBox.decryptStringDetached(
        c.cipher, c.mac, nonce, alice.publicKey, bob.secretKey);

    assert(msg == decrypted);
    print('decrypted: $decrypted');
    // END box2
  }

  void box3(Function(Object) print) {
    // BEGIN box3: Precalculated combined mode: The authentication tag and the encrypted message are stored together.
    // Generate key pairs
    final alice = CryptoBox.randomKeys();
    final bob = CryptoBox.randomKeys();
    final nonce = CryptoBox.randomNonce();

    // Alice encrypts message for Bob
    final msg = 'hello world';
    final encrypted =
        CryptoBox.encryptString(msg, nonce, bob.publicKey, alice.secretKey);

    print(hex.encode(encrypted));

    // Bob decrypts message from Alice (precalculated)
    final key = CryptoBox.sharedSecret(alice.publicKey, bob.secretKey);
    final decrypted = CryptoBox.decryptStringAfternm(encrypted, nonce, key);

    assert(msg == decrypted);
    print('decrypted: $decrypted');
    // END box3
  }

  void box4(Function(Object) print) {
    // BEGIN box4: Precalculated detached mode: The authentication tag and the encrypted message are detached so they can be stored at different locations.
    // Generate key pairs
    final alice = CryptoBox.randomKeys();
    final bob = CryptoBox.randomKeys();
    final nonce = CryptoBox.randomNonce();

    // Alice encrypts message for Bob (precalculated)
    final key = CryptoBox.sharedSecret(bob.publicKey, alice.secretKey);
    final msg = 'hello world';
    final c = CryptoBox.encryptStringDetachedAfternm(msg, nonce, key);

    print('cipher: ${hex.encode(c.cipher)}');
    print('mac: ${hex.encode(c.mac)}');

    // Bob decrypts message from Alice
    final decrypted = CryptoBox.decryptStringDetached(
        c.cipher, c.mac, nonce, alice.publicKey, bob.secretKey);

    assert(msg == decrypted);
    print('decrypted: $decrypted');
    // END box4
  }

  void box5(Function(Object) print) {
    // BEGIN box5: Usage: Anonymous sender encrypts a message intended for recipient only.
    // Recipient creates a long-term key pair
    final keys = SealedBox.randomKeys();

    // Anonymous sender encrypts a message using an ephemeral key pair and the recipient's public key
    final msg = 'hello world';
    final cipher = SealedBox.sealString(msg, keys.publicKey);

    print('cipher: ${hex.encode(cipher)}');

    // Recipient decrypts the ciphertext
    final decrypted = SealedBox.openString(cipher, keys);

    assert(msg == decrypted);
    print('decrypted: $decrypted');
    // END box5
  }

  void secret1(Function(Object) print) {
    // BEGIN secret1: Combined mode: The authentication tag and the encrypted message are stored together.
    // Generate random secret and nonce
    final key = SecretBox.randomKey();
    final nonce = SecretBox.randomNonce();

    // encrypt
    final msg = 'hello world';
    final encrypted = SecretBox.encryptString(msg, nonce, key);
    print(hex.encode(encrypted));

    // decrypt
    final decrypted = SecretBox.decryptString(encrypted, nonce, key);
    assert(msg == decrypted);
    // END secret1
  }

  void secret2(Function(Object) print) {
    // BEGIN secret2: Detached mode: The authentication tag and the encrypted message are detached so they can be stored at different locations.
    // Generate random secret and nonce
    final key = SecretBox.randomKey();
    final nonce = SecretBox.randomNonce();

    // encrypt
    final msg = 'hello world';
    final c = SecretBox.encryptStringDetached(msg, nonce, key);
    print('cipher: ${hex.encode(c.cipher)}');
    print('mac: ${hex.encode(c.mac)}');

    // decrypt
    final decrypted =
        SecretBox.decryptStringDetached(c.cipher, c.mac, nonce, key);

    assert(msg == decrypted);
    // END secret2
  }

  void sign1(Function(Object) print) {
    // BEGIN sign1: Combined mode: Compute a signed message
    final msg = 'hello world';
    final keys = CryptoSign.randomKeys();

    // sign with secret key
    final signed = CryptoSign.signString(msg, keys.secretKey);
    print('signed: ${hex.encode(signed)}');

    // verify with public key
    final unsigned = CryptoSign.openString(signed, keys.publicKey);
    print('unsigned: $unsigned');

    assert(msg == unsigned);
    // END sign1
  }

  void sign2(Function(Object) print) {
    // BEGIN sign2: Detached mode: Compute a signature
    // Author generates keypair
    final keys = CryptoSign.randomKeys();

    // Author computes signature using secret key
    final msg = 'hello world';
    final sig = CryptoSign.signStringDetached(msg, keys.secretKey);
    print(hex.encode(sig));

    // Recipient verifies message was issued by author using public key
    final valid = CryptoSign.verifyString(sig, msg, keys.publicKey);

    assert(valid);
    // END sign2
  }

  Future sign3(Function(Object) print) async {
    // BEGIN sign3: Multi-part message: Compute a signature for multiple messages.
    // Author generates keypair
    final keys = CryptoSign.randomKeys();

    // Author computes signature using secret key
    final parts = ['Arbitrary data to hash', 'is longer than expected'];
    final sig = await CryptoSign.signStrings(
        Stream.fromIterable(parts), keys.secretKey);
    print(hex.encode(sig));

    // Recipient verifies message was issued by author using public key
    final valid = await CryptoSign.verifyStrings(
        sig, Stream.fromIterable(parts), keys.publicKey);

    assert(valid);
    // END sign3
  }

  void sign4(Function(Object) print) {
    // BEGIN sign4: Secret key extraction: Extracts seed and public key from a secret key.
    final seed = CryptoSign.randomSeed();
    final keys = CryptoSign.seedKeys(seed);

    print('seed: ${hex.encode(seed)}');
    print('pk: ${hex.encode(keys.publicKey)}');
    print('sk: ${hex.encode(keys.secretKey)}');

    final s = CryptoSign.extractSeed(keys.secretKey);
    final pk = CryptoSign.extractPublicKey(keys.secretKey);

    // assert equality
    final eq = ListEquality().equals;
    assert(eq(s, seed));
    assert(eq(pk, keys.publicKey));
    // END sign4
  }

  void sign5(Function(Object) print) {
    // BEGIN sign5: Usage: Converts an Ed25519 key pair to a Curve25519 key pair.
    var k = CryptoSign.randomKeys();
    print('ed25519 pk: ${hex.encode(k.publicKey)}');
    print('ed25519 sk: ${hex.encode(k.secretKey)}');

    var pk = Sodium.cryptoSignEd25519PkToCurve25519(k.publicKey);
    var sk = Sodium.cryptoSignEd25519SkToCurve25519(k.secretKey);
    print('curve25519 pk: ${hex.encode(pk)}');
    print('curve25519 sk: ${hex.encode(sk)}');
    // END sign5
  }

  void generic1(Function(Object) print) {
    // BEGIN generic1: Single-part without a key:
    final value = 'Arbitrary data to hash';
    final hash = GenericHash.hashString(value);

    print(hex.encode(hash));
    // END generic1
  }

  void generic2(Function(Object) print) {
    // BEGIN generic2: Single-part with a key:
    final value = 'Arbitrary data to hash';
    final key = GenericHash.randomKey();

    final hash = GenericHash.hashString(value, key: key);

    print(hex.encode(hash));
    // END generic2
  }

  Future generic3(Function(Object) print) async {
    // BEGIN generic3: Multi-part without a key: Should result in a hash equal to the single-part without a key sample.
    final stream = Stream.fromIterable(['Arbitrary data ', 'to hash']);

    final hash = await GenericHash.hashStrings(stream);

    print(hex.encode(hash));
    // END generic3
  }

  Future generic4(Function(Object) print) async {
    // BEGIN generic4: Multi-part with a key:
    final stream = Stream.fromIterable(
        ['Arbitrary data to hash', 'is longer than expected']);
    final key = GenericHash.randomKey();

    final hash = await GenericHash.hashStrings(stream, key: key);

    print(hex.encode(hash));
    // END generic4
  }

  void pwhash1(Function(Object) print) {
    // BEGIN pwhash1: Hash: Derives a hash from given password and salt.
    final pw = 'hello world';
    final salt = PasswordHash.randomSalt();
    final hash = PasswordHash.hashString(pw, salt);

    print(hex.encode(hash));
    // END pwhash1
  }

  void pwhash2(Function(Object) print) {
    // BEGIN pwhash2: Hash storage: Computes a password verification string for given password.
    final pw = 'hello world';
    final str = PasswordHash.hashStringStorage(pw);
    print(str);

    // verify storage string
    final valid = PasswordHash.verifyStorage(str, pw);
    print('Valid: $valid');
    // END pwhash2
  }

  Future pwhash3(Function(Object) print) async {
    // BEGIN pwhash3: Hash storage async: Execute long running hash operation in background using Flutter's compute.
    // time operation
    final watch = Stopwatch();
    watch.start();

    // compute hash
    final pw = 'hello world';
    final str = await compute(PasswordHash.hashStringStorageModerate, pw);

    print(str);
    print('Compute took ${watch.elapsedMilliseconds}ms');
    watch.stop();
    // END pwhash3
  }

  void shorthash1(Function(Object) print) {
    // BEGIN shorthash1: Usage: Computes a fixed-size fingerprint for given string value and key.
    final m = 'hello world';
    final k = ShortHash.randomKey();
    final h = ShortHash.hashString(m, k);

    print(hex.encode(h));
    // END shorthash1
  }

  void kdf1(Function(Object) print) {
    // BEGIN kdf1: Usage: Derive subkeys.
    // random master key
    final k = KeyDerivation.randomKey();

    // derives subkeys of various lengths
    final k1 = KeyDerivation.derive(k, 1, subKeyLength: 32);
    final k2 = KeyDerivation.derive(k, 2, subKeyLength: 32);
    final k3 = KeyDerivation.derive(k, 3, subKeyLength: 64);

    print('subkey1: ${hex.encode(k1)}');
    print('subkey2: ${hex.encode(k2)}');
    print('subkey3: ${hex.encode(k3)}');
    // END kdf1
  }

  void kx1(Function(Object) print) {
    // BEGIN kx1: Usage: Compute a set of shared keys.
    // generate key pairs
    final c = KeyExchange.randomKeys();
    final s = KeyExchange.randomKeys();

    // compute session keys
    final ck = KeyExchange.computeClientSessionKeys(c, s.publicKey);
    final sk = KeyExchange.computeServerSessionKeys(s, c.publicKey);

    // assert keys do match
    final eq = ListEquality().equals;
    assert(eq(ck.rx, sk.tx));
    assert(eq(ck.tx, sk.rx));

    print('client rx: ${hex.encode(ck.rx)}');
    print('client tx: ${hex.encode(ck.tx)}');
    // END kx1
  }

  Future scalarmult1(Function(Object) print) async {
    // BEGIN scalarmult1: Usage: Computes a shared secret.
    // client keys
    final csk = ScalarMult.randomSecretKey();
    final cpk = ScalarMult.computePublicKey(csk);

    // server keys
    final ssk = ScalarMult.randomSecretKey();
    final spk = ScalarMult.computePublicKey(ssk);

    // client derives shared key
    final cq = ScalarMult.computeSharedSecret(csk, spk);
    final cs =
        await GenericHash.hashStream(Stream.fromIterable([cq, cpk, spk]));

    // server derives shared key
    final sq = ScalarMult.computeSharedSecret(ssk, cpk);
    final ss =
        await GenericHash.hashStream(Stream.fromIterable([sq, cpk, spk]));

    // assert shared keys do match
    final eq = ListEquality().equals;
    assert(eq(cs, ss));

    print(hex.encode(cs));
    // END scalarmult1
  }

  void chacha1(Function(Object) print) {
    // BEGIN chacha1: Combined mode: The authentication tag is directly appended to the encrypted message.
    // random nonce and key
    final n = ChaCha20Poly1305.randomNonce();
    final k = ChaCha20Poly1305.randomKey();
    print('nonce: ${hex.encode(n)}');
    print('key: ${hex.encode(k)}');

    // encrypt
    final m = 'hello world';
    final d = '123456';
    final c = ChaCha20Poly1305.encryptString(m, n, k, additionalData: d);

    print('cipher: ${hex.encode(c)}');

    // decrypt
    final s = ChaCha20Poly1305.decryptString(c, n, k, additionalData: d);

    assert(m == s);
    // END chacha1
  }

  void chacha2(Function(Object) print) {
    // BEGIN chacha2: Detached mode: The authentication tag and the encrypted message are detached so they can be stored at different locations.
    // random nonce and key
    final n = ChaCha20Poly1305.randomNonce();
    final k = ChaCha20Poly1305.randomKey();
    print('nonce: ${hex.encode(n)}');
    print('key: ${hex.encode(k)}');

    // encrypt
    final m = 'hello world';
    final d = '123456';
    final c =
        ChaCha20Poly1305.encryptStringDetached(m, n, k, additionalData: d);

    print('cipher: ${hex.encode(c.cipher)}');
    print('mac: ${hex.encode(c.mac)}');

    // decrypt
    final s = ChaCha20Poly1305.decryptStringDetached(c.cipher, c.mac, n, k,
        additionalData: d);

    assert(m == s);
    // END chacha2
  }

  void chachaietf1(Function(Object) print) {
    // BEGIN chachaietf1: Combined mode: The authentication tag is directly appended to the encrypted message.
    // random nonce and key
    final n = ChaCha20Poly1305Ietf.randomNonce();
    final k = ChaCha20Poly1305Ietf.randomKey();
    print('nonce: ${hex.encode(n)}');
    print('key: ${hex.encode(k)}');

    // encrypt
    final m = 'hello world';
    final d = '123456';
    final c = ChaCha20Poly1305Ietf.encryptString(m, n, k, additionalData: d);

    print('cipher: ${hex.encode(c)}');

    // decrypt
    final s = ChaCha20Poly1305Ietf.decryptString(c, n, k, additionalData: d);

    assert(m == s);
    // END chachaietf1
  }

  void chachaietf2(Function(Object) print) {
    // BEGIN chachaietf2: Detached mode: The authentication tag and the encrypted message are detached so they can be stored at different locations.
    // random nonce and key
    final n = ChaCha20Poly1305Ietf.randomNonce();
    final k = ChaCha20Poly1305Ietf.randomKey();
    print('nonce: ${hex.encode(n)}');
    print('key: ${hex.encode(k)}');

    // encrypt
    final m = 'hello world';
    final d = '123456';
    final c =
        ChaCha20Poly1305Ietf.encryptStringDetached(m, n, k, additionalData: d);

    print('cipher: ${hex.encode(c.cipher)}');
    print('mac: ${hex.encode(c.mac)}');

    // decrypt
    final s = ChaCha20Poly1305Ietf.decryptStringDetached(c.cipher, c.mac, n, k,
        additionalData: d);

    assert(m == s);
    // END chachaietf2
  }

  void xchachaietf1(Function(Object) print) {
    // BEGIN xchachaietf1: Combined mode: The authentication tag is directly appended to the encrypted message.
    // random nonce and key
    final n = XChaCha20Poly1305Ietf.randomNonce();
    final k = XChaCha20Poly1305Ietf.randomKey();
    print('nonce: ${hex.encode(n)}');
    print('key: ${hex.encode(k)}');

    // encrypt
    final m = 'hello world';
    final d = '123456';
    final c = XChaCha20Poly1305Ietf.encryptString(m, n, k, additionalData: d);

    print('cipher: ${hex.encode(c)}');

    // decrypt
    final s = XChaCha20Poly1305Ietf.decryptString(c, n, k, additionalData: d);

    assert(m == s);
    // END xchachaietf1
  }

  void xchachaietf2(Function(Object) print) {
    // BEGIN xchachaietf2: Detached mode: The authentication tag and the encrypted message are detached so they can be stored at different locations.
    // random nonce and key
    final n = XChaCha20Poly1305Ietf.randomNonce();
    final k = XChaCha20Poly1305Ietf.randomKey();
    print('nonce: ${hex.encode(n)}');
    print('key: ${hex.encode(k)}');

    // encrypt
    final m = 'hello world';
    final d = '123456';
    final c =
        XChaCha20Poly1305Ietf.encryptStringDetached(m, n, k, additionalData: d);

    print('cipher: ${hex.encode(c.cipher)}');
    print('mac: ${hex.encode(c.mac)}');

    // decrypt
    final s = XChaCha20Poly1305Ietf.decryptStringDetached(c.cipher, c.mac, n, k,
        additionalData: d);

    assert(m == s);
    // END xchachaietf2
  }
}
