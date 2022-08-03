export default function timeDiff(date1: Date | null, date2: number) {
  return date1 ? Math.abs(date1.getTime() - date2) / 1000 : false;
}
