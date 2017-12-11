
onstart:
    shell("mail -s 'Workflow started' email_address < {log}")

onsuccess:
    shell("mail -s 'Workflow finished, no error' email_address < {log}")

onerror:
    shell("mail -s 'an error occurred' email_address < {log}")