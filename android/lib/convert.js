export function timestampToElapsed(timestamp) {
  var elapsed = '';
  var date = new Date(timestamp);
  var seconds = new Date().getTime() - date.getTime();

  seconds = Math.floor(seconds / 1000);

  if (seconds < 60) {
    elapsed = 'Just now';
  } else if (seconds < 60 * 60) {
    var minutes = Math.floor(seconds / 60);
    var text = minutes > 1 ? 'mins' : 'min';
    elapsed = minutes + ' ' + text;
  } else if (seconds < 24 * 60 * 60) {
    var hours = Math.floor(seconds / (60 * 60));
    var text = hours > 1 ? 'hours' : 'hour';
    elapsed = hours + ' ' + text;
  } else {
    var days = Math.floor(seconds / (24 * 60 * 60));
    var text = days > 1 ? 'days' : 'day';
    elapsed = days + ' ' + text;
  }

  return elapsed;
}

export function componentsToBirthDate(date) {
  const day = `0${date.getDate()}`.slice(-2);
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return `${day}-${months[date.getMonth()]}-${date.getFullYear()}`;
}

export function todayToReverse() {
  const time = Math.floor(new Date().getTime() / 1000);
  const original = time.toString();

  let reverse = '';
  for (var i = original.length - 1; i >= 0; i--) {
    reverse += original[i];
  }

  return reverse;
}

// Convert milliseconds to seconds
export function msToSeconds(ms) {
  return Math.floor(ms / 1000);
}

function padTo2Digits(num) {
  return num.toString().padStart(2, '0');
}

export function convertMsToTime(milliseconds) {
  let seconds = Math.floor(milliseconds / 1000);
  let minutes = Math.floor(seconds / 60);

  seconds = seconds % 60;
  minutes = minutes % 60;

  return `${padTo2Digits(minutes)}:${padTo2Digits(seconds)}`;
}

export function formatMs(milliseconds) {
  let ms = milliseconds;
  let seconds = Math.floor(milliseconds / 1000);
  let minutes = Math.floor(seconds / 60);

  ms = milliseconds % 1000;
  seconds = seconds % 60;
  minutes = minutes % 60;

  return `${padTo2Digits(minutes)}:${padTo2Digits(seconds)}:${padTo2Digits(
    ms,
  ).slice(0, 2)}`;
}
