export function arrayUnion(array: any[], element: any) {
  return [...new Set([...array, element])];
}

export function arrayRemove(array: any[], element: any) {
  return array.filter((e) => e !== element);
}
