%{
  title: "Interactive vs. Non-Interactive Shells",
  date: "2025-04-24",
  id: "3",
  tags: ~w(linux ssh public note), 
  summary: "The differences between the two can cause problems for you."
}
---

The environment provided to a shell session depends on the user that starts the session and **how** they started the session.

Interactive shell sessions will evaluate the `.bashrc` file which provides all of the environment that you are used to. Non-interactive shells will not. 

I ran into this when trying to run scripts via ssh that relied on environment variables exported in `.bashrc`. After googling and asking an LLM (clauding?) the solution I went with was changing the ssh config file to allow user environments (on ubuntu setting `PermitUserEnvironment true` in /etc/ssh/sshd_config) and creating an environment file in the .ssh directory of the user running the script that exported the variables.

One final warning is that this environment file does **not** expand any shell variables that are used as the values of your exports.  So `export HELLO="$WORLD"` will give `$HELLO` the value `"$WORLD"` even if `$WORLD` is assigned a value earlier in the environment file. 
