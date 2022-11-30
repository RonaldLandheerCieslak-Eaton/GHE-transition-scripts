# 0. read out .env configuration file
# 1. read the CSV file with the list of repos to transition
# 2. for each repo, validate that the GHE name conforms to the naming standard. Tell the user which names we can automatically fix (and what the resulting name would be), and which we can't.
# 3. for each repo, validate that the JIRA board exists
# 4. for each repo, validate that the necessary GHE teams exist. Tell the use which teams to create if needed
# 5. for each repo, validate we can get it from BitBucket
# 6. look for file that smell like private keys
# 7. run GitLeaks
# 8. run TruffleHog
# 9. create the GHE repo
# 10. push

# See https://github.com/albing-eaton/import-to-ghe.git for steps 2, 5, 9, and 10

from dotenv import load_dotenv

load_dotenv()
