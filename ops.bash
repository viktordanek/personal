if [ "${1}" == "check" ]
then
    unset LD_LIBRARY_PATH &&
        nix flake check
elif [ "${1}" == "commit" ]
then
    unset LD_LIBRARY_PATH &&
        nix flake check &&
        shift &&
        git commit -am "${@}" --allow-empty --allow-empty-message
elif [ "${1}" == "scratch" ]
then
  git fetch origin main &&
    git fetch origin milestone ${2} &&
    git fetch origin issue/${2} &&
    git checkout origin/issue/${3} &&
    git checkout -b scratch/$(uuidgen) &&
    git rebase origin/milestone/${2} &&
    git rebase origin/main &&
    unset LD_LIBRARY_PATH &&
    nix flake check &&
    git commit -am "Closes #${3}" --allow-empty
fi