
doc = window.document;

accounts = [];
cumm_total = 0;
required = 0;
daysInPeriod = 0;

projects = doc.querySelectorAll('#timesheet tbody td.project');
accountRows = [];
for (var i = 0; i < projects.length; i++) {
    accountRows.push(projects[i].parentNode);
}
project_names = []
if (accountRows.length) required = (accountRows[0].querySelectorAll('.weekday-hours').length) * 8;
for (var i = 0; i < accountRows.length; i++) {
    hours = [];
    hourCells = accountRows[i].querySelectorAll('.weekday-hours input,.weekend-hours input')
    daysInPeriod = hourCells.length;
    for (var j = 0; j < hourCells.length; j++) {
        hours.push(hourCells[j].value === "" ? null : +hourCells[j].value);
    }

    total = +(accountRows[i].querySelector('.total input').value);
    cumm_total += total;
    select_box = accountRows[i].querySelector('.project select');
    account_name = select_box.selectedOptions[0].innerText;

    if (account_name.length && project_names.indexOf(account_name) === -1) {
            
        project_names.push(account_name);
        
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
                      total: total,
                      optionVal: select_box.selectedOptions[0].value
                      });
    }
}

project_options = doc.querySelectorAll('#timesheet tbody td.project select option');
for (var i = 0; i < project_options.length; i++) {
    project = project_options[i].innerText;
    if (project.length && project_names.indexOf(project) === -1) {
        project_names.push(project);
        
        account_name = project;
        account_code = '';
        match = account_name.match(/^\s*([\w\d]{4}-\d{3})\s+(.*)\s*$/);
        if (match) {
            account_name = match[2];
            account_code = match[1];
        }
        
        accounts.push({
                      unused: true,
                      name: account_name,
                      code: account_code,
                      hours: new Array(accounts[0].hours.length),
                      total: 0,
                      optionVal: project_options[i].value
                      });        
    }
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