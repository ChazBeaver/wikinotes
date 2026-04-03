<!-- # 🔐 GitLab HTTPS + GitHub SSH Access on macOS -->
<!--  -->
<!-- This guide explains how to configure Git to use: -->
<!-- - 🔐 **HTTPS (PAT)** for GitLab -->
<!-- - 🔑 **SSH** for GitHub -->
<!--  -->
<!-- --- -->
<!--  -->
<!-- ## 🔒 Step 1: Generate a Personal Access Token (PAT) for GitLab -->
<!--  -->
<!-- 1. Log into [GitLab](https://gitlab.com). -->
<!-- 2. Go to **Profile → Edit Profile → Access Tokens**. -->
<!-- 3. Fill out: -->
<!--    - **Name**: e.g., `macbook-pat` -->
<!--    - **Expiry date**: optional -->
<!--    - **Scopes**: ✅ `read_repository`, ✅ `write_repository`, ✅ `api` (if needed) -->
<!-- 4. Click **Create personal access token**. -->
<!-- 5. **Copy and save** the token securely. You won’t be able to see it again! -->
<!--  -->
<!-- --- -->
<!--  -->
<!-- ## 📦 Step 2: Clone Your Repos Using the Right Protocol -->
<!--  -->
<!-- - GitHub (SSH): -->
<!--  -->
<!--   ```bash -->
<!--   git clone git@github.com:your-username/your-repo.git -->
<!--   ``` -->
<!--  -->
<!-- - GitLab (HTTPS): -->
<!--  -->
<!--   ```bash -->
<!--   git clone https://gitlab.com/your-username/your-repo.git -->
<!--   ``` -->
<!--  -->
<!-- To verify which protocol your remote is using: -->
<!--  -->
<!-- ```bash -->
<!-- git remote -v -->
<!-- ``` -->
<!--  -->
<!-- --- -->
<!--  -->
<!-- ## 🔑 Step 3: Use macOS Keychain to Store GitLab PAT -->
<!--  -->
<!-- To avoid entering your PAT every time: -->
<!--  -->
<!-- ```bash -->
<!-- git config --global credential.helper osxkeychain -->
<!-- ``` -->
<!--  -->
<!-- macOS will then store and autofill the PAT securely. -->
<!--  -->
<!-- --- -->
<!--  -->
<!-- ## 📁 Step 3B: Safely Manage credential.helper in Version-Controlled Configs -->
<!--  -->
<!-- If your `.gitconfig` is tracked in Git (e.g., in dotfiles), do **not** include sensitive info like credential helpers in that file. -->
<!--  -->
<!-- Instead, use a **local-only Git config override**: -->
<!--  -->
<!-- 1. Create a `~/.gitconfig.local` file with: -->
<!--  -->
<!--    ```ini -->
<!--    [credential] -->
<!--        helper = osxkeychain -->
<!--    ``` -->
<!--  -->
<!-- 2. In your `.gitconfig`, include it like this: -->
<!--  -->
<!--    ```ini -->
<!--    [include] -->
<!--        path = ~/.gitconfig.local -->
<!--    ``` -->
<!--  -->
<!-- 3. Be sure to **exclude `~/.gitconfig.local` from version control**: -->
<!--  -->
<!--    ```bash -->
<!--    echo ".gitconfig.local" >> ~/.gitignore_global -->
<!--    git config --global core.excludesfile ~/.gitignore_global -->
<!--    ``` -->
<!--  -->
<!-- This way, secrets stay out of version-controlled configs. -->
<!--  -->
<!-- --- -->
<!--  -->
<!-- ## ⚙️ Step 4: SSH Config for GitHub (Optional but Recommended) -->
<!--  -->
<!-- If you're using SSH for GitHub, configure which key to use: -->
<!--  -->
<!-- 1. Open or create your SSH config file: -->
<!--  -->
<!--    ```bash -->
<!--    nano ~/.ssh/config -->
<!--    ``` -->
<!--  -->
<!-- 2. Add the following: -->
<!--  -->
<!--    ```ssh -->
<!--    Host github.com -->
<!--      HostName github.com -->
<!--      User git -->
<!--      IdentityFile ~/.ssh/id_ed25519_github -->
<!--    ``` -->
<!--  -->
<!--    > **📝 Note:**   -->
<!--    > The `IdentityFile` must point to a **real SSH private key** on your system.   -->
<!--    > You are responsible for generating the key and naming it appropriately.   -->
<!--    > If unsure, generate one with: -->
<!--    > -->
<!--    > ```bash -->
<!--    > ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -C "your_email@example.com" -->
<!--    > ``` -->
<!--  -->
<!-- 3. Test your SSH connection to GitHub: -->
<!--  -->
<!--    ```bash -->
<!--    ssh -T git@github.com -->
<!--    ``` -->
<!--  -->
<!-- --- -->
<!--  -->
<!-- ## ✅ Final Notes -->
<!--  -->
<!-- - Use **SSH for GitHub** and **HTTPS with PAT for GitLab** with no conflict. -->
<!-- - Git chooses the correct protocol based on each remote's URL. -->
<!-- - You can confirm everything is set correctly using: -->
<!--  -->
<!--   ```bash -->
<!--   git remote -v -->
<!--   ``` -->
<!--  -->
<!-- You're now fully configured for secure access to both GitHub and GitLab! -->
