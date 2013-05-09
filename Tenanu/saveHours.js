
var input = document.querySelectorAll('#r#{accountIndex} td input.hours')[#{dayIndex}];
input.value = '#{hours}';
changeCell(input);

$('button_save-button').click();
