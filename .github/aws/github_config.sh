## This is run after gh login to add the environment and secrets


./setup_github_environment.sh qld-gov-au site-myqldgovau DEV "s3://BUCKETGOESHERE" "arn:aws:iam::xxxx:role/xxxROLESGOLESHERExxx"
./setup_github_environment.sh qld-gov-au site-myqldgovau TEST "s3://BUCKETGOESHERE" "arn:aws:iam::xxxx:role/xxxROLESGOLESHERExxx"
./setup_github_environment.sh qld-gov-au site-myqldgovau STAGING "s3://BUCKETGOESHERE" "arn:aws:iam::xxxx:role/xxxROLESGOLESHERExxx"
./setup_github_environment.sh qld-gov-au site-myqldgovau PROD "s3://BUCKETGOESHERE" "arn:aws:iam::xxxx:role/xxxROLESGOLESHERExxx"
