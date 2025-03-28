mkdir github &&
mkdir github/viktordanek &&
OPS=$(pwd)/github/viktordanek/personal &&
for REPO in personal shell-scripts originator-pid environment-variable string standard-url cache temporary shell-script visitor bash-unit-checker tests invalid-value has-standard-input strip
do
  mkdir github/viktordanek/${REPO} &&
  git -C github/viktordanek/${REPO} init &&
  git -C github/viktordanek/${REPO} config user.name "Viktor Danek" &&
  git -C github/viktordanek/${REPO} config user.email "viktordanek10@gmail.com" &&
  git -C github/viktordanek/${REPO} config core.sshCommand "ssh -i ~/.ssh/victor.danek.id-rsa" &&
  git -C github/viktordanek/${REPO} remote add origin git@github.com:viktordanek/${REPO}.git &&
  git -C github/viktordanek/${REPO} fetch origin &&
  git -C github/viktordanek/${REPO} checkout origin/main &&
  git -C github/viktordanek/${REPO} checkout -b scratch/$(uuidgen) &&
  git -C github/viktordanek/${REPO} config alias.ops '!${OPS}/ops.bash' &&
  ( cat > github/viktordanek/${REPO}/.git/hooks/post-commit <<EOF
   while ! git push origin HEAD
   do
    sleep 1m
  done
EOF
  ) &&
  chmod 0500 github/viktordanek/${REPO}/.git/hooks/post-commit
done