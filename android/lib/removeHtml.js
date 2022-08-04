import he from 'he';

export function removeHtml(source) {
  return source ? he.decode(source.replace(/(<([^>]+)>)/gi, '')) : '';
}
