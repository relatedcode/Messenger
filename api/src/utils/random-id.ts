import { randomBytes } from "crypto";

export default function randomId(idLength: number, chars?: string) {
  chars =
    chars || "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  const rnd = randomBytes(idLength);
  const value = new Array(idLength);
  const len = Math.min(256, chars.length);
  const d = 256 / len;

  for (let i = 0; i < idLength; i++) {
    value[i] = chars[Math.floor(rnd[i] / d)];
  }

  return value.join("");
}
