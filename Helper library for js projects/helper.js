function concenateToPhrase(array, connectWord) {
    var length = array.length;
    var phrase = "";

    array.map((item) => {
        var index = array.indexOf(item);

        // return word if theres is only one item
        if(length == 1){
          phrase = item;

        } else if (length > 0){

            // it its the first word don't add a comma
            if(index === 0){
                phrase += item;

            // if item is in the middle add a comma
            } else if(index < (length - 1)) {
                phrase += ", " + item;

            // if item is at the end add connectWord
            } else if(index == (length -1)) {
                phrase += " " + connectWord + " " + item;
            }
        }
    });
    return phrase;
}

function getValue(obj, path) {
  for (var i=0, path = path.split('.'), len = path.length; i<len; i++){
    obj = obj[path[i]];
  }
  return obj;
}

function setValue(object, key, value) {
  key = key.split('.');
  for (var index = 0; index < key.length - 1; index++){
      object = object[key[index]];
  }
  object[key[index]] = value;
  return object;
}

function slugify(text){
  return text.toString().toLowerCase()
    .replace(/\s+/g, '-') // Replace spaces with -
    .replace(/[^\w\-]+/g, '') // Remove all non-word chars
    .replace(/\-\-+/g, '-') // Replace multiple - with single -
    .replace(/^-+/, '') // Trim - from start of text
    .replace(/-+$/, ''); // Trim - from end of text
}

function scorePassword(password) {
  var score = 0;
  if (!password)
    return score;

  // award every unique letter until 5 repetitions
  var letters = new Object();
  for (var i=0; i<password.length; i++) {
    letters[password[i]] = (letters[password[i]] || 0) + 1;
    score += 5.0 / letters[password[i]];
  }

  // bonus points for mixing it up
  var variations = {
    digits: /\d/.test(password),
    lower: /[a-z]/.test(password),
    upper: /[A-Z]/.test(password),
    nonWords: /\W/.test(password),
  }

  var variationCount = 0;
  for (var check in variations) {
    variationCount += (variations[check] === true) ? 1 : 0;
  }
  score += (variationCount - 1) * 10;

  return parseInt(score);
}

function checkPassStrength(password) {
  var score = scorePassword(password);
  if (score > 80)
    return "strong";
  if (score > 60)
    return "good";
  if (score >= 30)
    return "still weak";
  if (score >= 0)
    return "weak";

  return "";
}

export { setValue, slugify, scorePassword, checkPassStrength, getValue, concenateToPhrase }
