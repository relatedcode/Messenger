const createKey = (keys: any[]) => {
  let oneNull = false;
  let key = "";
  keys.forEach((item: any) => {
    if (!item) {
      oneNull = true;
    }
    key += item || "";
  });
  if (oneNull) return null;
  return key;
};

export default createKey;
