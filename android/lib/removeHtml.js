import he from 'he';

export function removeHtml(source) {
  return he.decode(source.replace(/(<([^>]+)>)/gi, ''));
}
