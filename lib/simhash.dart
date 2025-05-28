import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart'; // pub add crypto

class SimHash {
  // 获取字符串的 simhash 值
  static int getSimHash(String text) {
    final int hashBits = 64;
    final List<int> v = List<int>.filled(hashBits, 0);

    // 分词（简单按字符切分）
    final List<String> words = text.runes.map((rune) => String.fromCharCode(rune)).toList();

    for (final word in words) {
      final int hash = _murmurHash64A(utf8.encode(word), 0x12345678);
      for (int i = 0; i < hashBits; i++) {
        final bool bit = ((hash >> i) & 1) == 1;
        if (bit) {
          v[i] += 1;
        } else {
          v[i] -= 1;
        }
      }
    }

    int fingerprint = 0;
    for (int i = 0; i < hashBits; i++) {
      if (v[i] >= 0) {
        fingerprint |= (1 << i);
      }
    }

    return fingerprint;
  }

  // 计算两个 simhash 的汉明距离
  static int hammingDistance(int x, int y) {
    int z = x ^ y;
    int distance = 0;
    while (z != 0) {
      distance += z & 1;
      z >>= 1;
    }
    return distance;
  }

  // 相似度分数（0.0 ~ 1.0），distance 越小越相似
  static double similarity(int x, int y) {
    final int distance = hammingDistance(x, y);
    return 1.0 - (distance / 64.0);
  }

  // MurmurHash 64 位实现（简化版）
  static int _murmurHash64A(List<int> key, int seed) {
    final ByteData data = Uint8List(key.length).buffer.asByteData();
    for (int i = 0; i < key.length; i++) {
      data.setUint8(i, key[i]);
    }

    const int m = 0xc6a4a7935bd1e995;
    const int r = 47;
    int h = seed ^ (key.length * m);

    int i = 0;
    final int length = data.lengthInBytes;
    while (i + 8 <= length) {
      int k = data.getUint64(i, Endian.little);
      k *= m;
      k ^= k >> r;
      k *= m;
      h ^= k;
      h *= m;
      i += 8;
    }

    switch (length % 8) {
      case 7:
        h ^= data.getUint8(i + 6) << 48;
      case 6:
        h ^= data.getUint8(i + 5) << 40;
      case 5:
        h ^= data.getUint8(i + 4) << 32;
      case 4:
        h ^= data.getUint8(i + 3) << 24;
      case 3:
        h ^= data.getUint8(i + 2) << 16;
      case 2:
        h ^= data.getUint8(i + 1) << 8;
      case 1:
        h ^= data.getUint8(i) << 0;
        h *= m;
    }

    h ^= h >> r;
    h *= m;
    h ^= h >> r;

    return h & 0x7FFFFFFFFFFFFFFF;
  }

  static bool isSimilar(String t1, String t2, double threshold){
    final int hash1 = getSimHash(t1);
    final int hash2 = getSimHash(t2);

    final double sim = SimHash.similarity(hash1, hash2);
    return sim > threshold;
  }

  static bool areFirstThreeCharsEqual(String a, String b, int count) {
    if (a.length < count || b.length < count) {
      return false;
    }
    return a.substring(0, count) == b.substring(0, count);
  }
}