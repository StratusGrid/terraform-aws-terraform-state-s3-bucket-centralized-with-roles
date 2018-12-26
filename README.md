This is intended to be used by an organization for all of their own accounts. This does not protect access to DynamoDB locking of other accounts, it only restricts access S3 paths for each account.

This restriction is put in place by creating a unique role for each account, then creating an assumerole policy that trusts the corresponding account to assume it.
