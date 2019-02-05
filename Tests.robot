*** Settings ***
Resource  Tables.robot



*** Test Cases ***
Datatables.net
    &{datatables table}=  Prepare Table XPaths
    ...  table=//table[@id='example']
    ...  rows=/tbody/tr[@role='row']
    ...  cells=/td
    ...  column name cells=/thead/tr/th

    Open browser  https://datatables.net/examples/data_sources/dom  chrome

    ${col count}=  Get Column Count  ${datatables table}
    ${row count}=  Get Row Count  ${datatables table}
    ${cell 11}=  Get Cell Value  ${datatables table}  [1]  [1]
    ${cell 34}=  Get Cell Value  ${datatables table}  [3]  [4]
    ${office colnr}  Get Column Number By Name  ${datatables table}  Office

    Log to console  ${col count}
    Log to console  ${row count}
    Log to console  ${cell 11}
    Log to console  ${cell 34}
    Log to console  ${office colnr}


