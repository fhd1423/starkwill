/* eslint-disable eqeqeq */
import { BigNumberish } from "ethers";

export class StringsSequence {
  stringValues!: string[];
  sizeBytes!: number;
}

export class IntArray {
  values: BigNumberish[];

  constructor(values: BigNumberish[], public readonly sizeBytes: number) {
    this.values = values.map((e) => BigInt(e));
  }

  toStrings(): StringsSequence {
    return {
      stringValues: this.values.map((e) => e.toString()),
      sizeBytes: this.sizeBytes,
    };
  }
}

export class Data {
  constructor(
    private readonly rawBytes: Buffer,
    private readonly oddNibbles: boolean = false
  ) {}

  static fromInts(input: IntArray): Data {
    const fullWords = Math.floor(input.sizeBytes / 8);
    const remainder = input.sizeBytes % 8;

    const buffers: Buffer[] = [];

    for (let i = 0; i < fullWords; i++) {
      const bytes = Data.fromHex(input.values[i].toString(16)).toBytes();
      if (bytes.length < 8) {
        buffers.push(Buffer.from(Array(8 - bytes.length).fill(0)));
      }
      buffers.push(bytes);
    }

    if (remainder > 0) {
      const bytes = Data.fromHex(
        input.values[fullWords].toString(16)
      ).toBytes();
      if (bytes.length < remainder) {
        buffers.push(Buffer.from(Array(remainder - bytes.length).fill(0)));
      }
      buffers.push(bytes);
    }

    return new Data(Buffer.concat(buffers));
  }

  static fromNibbles(rawNibbles: number[]): Data {
    if (rawNibbles.length == 0) return new Data(Buffer.from([]));

    const bytes: number[] = [];

    const oddNibbles = rawNibbles.length % 2 != 0;
    const nibbles = oddNibbles ? [0].concat(rawNibbles) : rawNibbles;

    for (let i = 0; i < nibbles.length; i += 2) {
      const byte = nibbles[i] * 2 ** 4 + nibbles[i + 1];
      bytes.push(byte);
    }

    return new Data(Buffer.from(bytes), oddNibbles);
  }

  static fromBytes(input: Buffer): Data {
    return new Data(input);
  }

  static fromHex(input: string): Data {
    if (input == "" || input == "0x") return new Data(Buffer.from([]));
    const prefixed = input.slice(0, 2) == "0x";
    return new Data(Buffer.from(prefixed ? input.slice(2) : input, "hex"));
  }

  toInts(): IntArray {
    if (this.rawBytes.length == 0) return new IntArray([], 0);

    const intsArray: BigNumberish[] = [];

    for (let i = 0; i < this.rawBytes.length; i += 8) {
      const chunk = this.rawBytes.slice(
        i,
        Math.min(i + 8, this.rawBytes.length)
      );
      intsArray.push(BigInt(`0x${chunk.toString("hex")}`));
    }

    return new IntArray(intsArray, this.rawBytes.length);
  }

  toHex(): string {
    return `0x${this.rawBytes.toString("hex")}`;
  }

  toBytes(): Buffer {
    return this.rawBytes;
  }

  toNibbles(): number[] {
    const nibbles: number[] = [];

    for (const byte of this.rawBytes) {
      nibbles.push(byte >> 4);
      nibbles.push(byte % 2 ** 4);
    }
    return this.oddNibbles ? nibbles.slice(1) : nibbles;
  }
}
