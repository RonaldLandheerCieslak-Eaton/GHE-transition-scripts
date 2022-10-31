#This scriprt uses the GH CLI: https://github.com/cli/cli/releases
#And for cleanup it uses GitRewrite: https://github.com/TimHeinrich/GitRewrite/releases

$description = 'ESP Sample' #optional repo desciption text
$oldProjectName = 'ltk'
$newProjectName = 'eaton-sandbox'

$oldRepoName = 'esp32_sample_app'
$newRepoName = 'rtos-esp32-sample-app'

$teamName = 'rtos'

$repoOwnerPAT = 'ghp_'

$primaryBranchName = 'develop'


#login to GH
echo $repoOwnerPAT | gh auth login --with-token 


#download the old repo, and cd into the folder
$oldRepoPath = "ssh://git@bitbucket-prod.tcc.etn.com:7999/$oldProjectName/$oldRepoName.git"
cls
git clone --bare "$oldRepoPath"
cd "$oldRepoName.git"

#To find large files run this from git bash
#git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '/^blob/ {print substr($0,6)}' | awk '$2 >= 25*1024^2' | sort --numeric-sort --key=2 --reverse | cut --complement --characters=13-40 | numfmt --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest


##!!!!!!!!!!!!!!!!  IMPORTANT    !!!!!!!!!!!!!!!!!
#run cleanup steps manually here before continuing!
GitRewrite .\ -d "RTK DCI DB Creator.txt"
GitRewrite .\ -d *.zip,*.chm,*.7z 
GitRewrite .\ -D  /Docs   
GitRewrite .\ -e
GitRewrite .\ --fix-trees
git reflog expire --expire=now --all
#this next step take the longest, 30 min...1 hour....
git gc --aggressive

#create the new repo on GitHub
gh repo create "$newProjectName/$newRepoName" --private -y -d $description

#add remote and push branches and then tags
git remote add ghmirror https://github.com/$newProjectName/$newRepoName.git
git push -u ghmirror --all
git push -u ghmirror --tags


#add teams to your repo and set their pemission levels: https://docs.github.com/en/rest/teams/teams#add-or-update-team-repository-permissions
gh api `
  --method PUT `
  -H "Accept: application/vnd.github+json" `
  /orgs/$newProjectName/teams/$teamName/repos/$newProjectName/$newRepoName `
  -f permission='admin'


#fix repo settings, choose your settings from here: https://cli.github.com/manual/gh_repo_edit
gh repo edit "$newProjectName/$newRepoName" --default-branch $primaryBranchName --enable-projects=false --enable-issues=false --enable-wiki=false --enable-squash-merge --enable-rebase-merge=false --enable-merge-commit=false --enable-projects=false --delete-branch-on-merge

#turn on branch protection for admins on $primaryBranchName
 gh api `
 --method PUT `
 -H "Accept: application/vnd.github+json" `
 /repos/$newProjectName/$newRepoName/branches/$primaryBranchName/protection `
 -F required_pull_request_reviews='null' `
 -F enforce_admins='true' `
 -F required_status_checks='null' `
 -F restrictions='null' `
 -F required_conversation_resolution='true'

 #more branch protection settings: required_pull_request_reviews
  gh api `
 --method PATCH  `
 -H "Accept: application/vnd.github+json" `
 /repos/$newProjectName/$newRepoName/branches/$primaryBranchName/protection/required_pull_request_reviews `
 -F dismiss_stale_reviews='true' `
 -F require_code_owner_reviews='true' `
 -F required_approving_review_count='1'

cd ..



#!!!!!!!!   Verifications
# TAGS in GitHub
# Branches on GitHub
# manually check permissions
# delete any stale Non RELEASE branches!

# fix submodules if any cleanup was done

