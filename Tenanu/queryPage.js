
doc = window.document;

accounts = [];
cumm_total = 0;
required = 0;
daysInPeriod = 0;

accountRows = doc.querySelectorAll('.timesheet table tbody tr');
if (accountRows.length) required = (accountRows[0].querySelectorAll('.weekday').length) * 8;
for (var i = 0; i < accountRows.length; i++) {
    hours = [];
    hourCells = accountRows[i].querySelectorAll('.weekday,.weekend')
    daysInPeriod = hourCells.length;
    for (var j = 0; j < hourCells.length; j++) {
        hours.push(hourCells[j].innerText === "" ? null : +hourCells[j].innerText);
    }
    accountCells = accountRows[i].querySelectorAll('td');
    total = +(accountRows[i].querySelector('.total').innerText);
    cumm_total += total;
    account_name = accountCells[0].innerText;
    account_code = '';
    match = account_name.match(/^\s*([\w\d]{4}-\d{3})\s+(.*)\s*$/);
    if (match) {
        account_name = match[2];
        account_code = match[1];
    }
    accounts.push({
                  name: account_name,
                  code: account_code,
                  hours: hours,
                  total: total
                  });
}


firstDate = doc.querySelector('#page-title #title-subsection').innerText;
firstDateMatch = firstDate.match(/.*\(([^-]+?)\s*-.*/);
start = new Date(firstDateMatch[1]);

month = start.getMonth() + 1;
dayOfMonth = start.getDate();
year = start.getFullYear()

result = accounts.length == 0 ?
  '' :
  JSON.stringify({
    startDate: [year, month, dayOfMonth],
    daysInPeriod: daysInPeriod,
    accounts: accounts,
    total: cumm_total,
    required: required
  });


result;