

var selects = document.querySelectorAll('#timesheet .project select');

var accountSelect = null;
for (var i = 0; i < selects.length; i++) {
    var select = selects[i];
    if (select.value === '#{accountValue}') {
        accountSelect = select;
        break;
    } else if (select.value === '') {
        accountSelect = select;
        accountSelect.value = '#{accountValue}';
        changeProject(accountSelect);
        break;
    }
}

var parent = accountSelect;
do {
    parent = parent.parentNode;
} while (parent && parent.nodeName !== 'TR');

var input = parent.querySelectorAll('td input.hours')[#{dayIndex}];
input.value = '#{hours}';
changeCell(input);

document.getElementById('button_save-button').click();
