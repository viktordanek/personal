mkdir repos &
mkdir repos/github &&
mkdir repos/github/viktordanek &&
for REPO in personal shell-scripts originator-pid environment-variable string standard-url cache temporary shell-script visitor bash-unit-checker tests invalid-value has-standard-input strip
do
  mkdir repos/github/viktordanek/${REPO} &&
  git -C repos/github/viktordanek/${REPO} init &&
  git -C repos/github/viktordanek/${REPO} config user.name "Viktor Danek" &&
  git -C repos/github/viktordanek/${REPO} config user.email "viktordanek10@gmail.com" &&
  git -C repos/github/viktordanek/${REPO} config core.sshCommand "ssh -i ~/.ssh/victor.danek.id-rsa" &&
  git -C repos/github/viktordanek/${REPO} remote add origin git@github.com:viktordanek/${REPO}.git &&
  git -C repos/github/viktordanek/${REPO} fetch origin &&
  git -C repos/github/viktordanek/${REPO} checkout origin/main &&
  git -C repos/github/viktordanek/${REPO} checkout -b scratch/$(uuidgen) &&
  git -C repos/github/viktordanek/${REPO} config alias.ops '!../../../../bin/ops.bash' &&
  ln --symbolic $(pwd)/bin/post-commit repos/github/viktordanek/${REPO}/.git/hooks/post-commit
done &&
  mkdir bin &&
  ( cat > bin/post-commit <<EOF
while ! git push origin HEAD
do
  sleep 1m
done
EOF
  ) &&
  chmod 0555 bin/post-commit &&
  ( cat > bin/ops.bash <<EOF
#!/usr/bin/env bash
if [ "\${1}" == "nix" ]
then
  unshift &&
    \${@}
fi
EOF
  ) &&
  chmod 0555 bin/ops.bash