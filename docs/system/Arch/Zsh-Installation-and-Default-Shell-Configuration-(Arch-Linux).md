======================================================================
Zsh Installation and Default Shell Configuration (Arch Linux)         
======================================================================


This guide documents how to install Zsh on Arch Linux and configure it 
as the default login shell for a user account.                         

The goal is to replace Bash (or another shell) with Zsh in a clean,    
reversible, and verifiable way using standard Arch Linux tooling.     


----------------------------------------------------------------------
Prerequisites                                                          
----------------------------------------------------------------------


- Arch Linux system                                                    
- sudo access                                                          
- Terminal access                                                      


----------------------------------------------------------------------
Step 1: Identify the Current Default Shell                              
----------------------------------------------------------------------


Before making changes, determine which shell is currently configured  
as your default login shell.                                           



Run the following command in your terminal:                            

  echo "$SHELL"                                                        



Common outputs:                                                        

  /bin/bash    → Bash is the default shell                              
  /usr/bin/zsh → Zsh is already the default shell                       



This value reflects the shell defined for your user account, not just 
the shell of the current process.                                      


----------------------------------------------------------------------
Step 2: Install Zsh                                                     
----------------------------------------------------------------------


Ensure package metadata is up to date (optional but recommended):     

  sudo pacman -Sy                                                      



Install the Zsh package:                                               

  sudo pacman -S zsh                                                   



Verify that Zsh is installed correctly:                                

  zsh --version                                                        



A version string confirms successful installation.                    


----------------------------------------------------------------------
Step 3: Locate the Zsh Binary Path                                      
----------------------------------------------------------------------


The chsh command requires the full path to the shell binary.           



Determine the Zsh binary location:                                     

  command -v zsh                                                       



On Arch Linux, this typically resolves to:                             

  /usr/bin/zsh                                                         


----------------------------------------------------------------------
Step 4: Set Zsh as the Default Login Shell                               
----------------------------------------------------------------------


Use chsh to update the shell associated with your user account.        



Run the following command:                                             

  chsh -s "$(command -v zsh)"                                          



Notes:                                                                 

- You will be prompted for your user password                          
- This modifies your login shell for future sessions                   
- The change does NOT apply to already-open terminals                  


----------------------------------------------------------------------
Step 5: Apply the Shell Change                                          
----------------------------------------------------------------------


For the shell change to take effect, you must start a new login session



Choose ONE of the following:                                           

- Log out of your desktop session and log back in                      
- Close all terminal windows and open a new one                        


----------------------------------------------------------------------
Step 6: Verify Zsh Is Now the Default Shell                              
----------------------------------------------------------------------


After starting a new session, verify the change using the same command
from Step 1.                                                          



Run:                                                                  

  echo "$SHELL"                                                        



Expected output:                                                       

  /usr/bin/zsh                                                         



If this value is correct, Zsh is now your default login shell.         


----------------------------------------------------------------------
Step 7: Create a Basic Zsh Configuration (Optional)                     
----------------------------------------------------------------------


Zsh reads user configuration from ~/.zshrc.                            



Create the file if it does not already exist:                          

  touch ~/.zshrc                                                       



Minimal recommended baseline configuration:                            



  export EDITOR=nvim                                                   

  HISTFILE=~/.zsh_history                                              
  HISTSIZE=10000                                                       
  SAVEHIST=10000                                                       

  setopt hist_ignore_dups                                              
  setopt share_history                                                 
  setopt autocd                                                        
  setopt correct                                                       

  autoload -Uz compinit && compinit                                    



Reload Zsh without closing the terminal (optional):                    

  exec zsh                                                             


----------------------------------------------------------------------
Troubleshooting                                                        
----------------------------------------------------------------------


If the shell does not change after logout/login:                       



1. Confirm Zsh is installed:                                           

  pacman -Qi zsh                                                       



2. Ensure Zsh is listed in /etc/shells:                                

  grep zsh /etc/shells                                                 



If missing (rare), add it manually:                                    

  command -v zsh | sudo tee -a /etc/shells                             



Then retry setting the default shell:                                  

  chsh -s "$(command -v zsh)"                                          


----------------------------------------------------------------------
Notes and Best Practices                                               
----------------------------------------------------------------------


- chsh affects the login shell, not per-terminal overrides             
- Terminal applications may still override shells via profiles         
- Zsh configuration should live in ~/.zshrc, not ~/.bashrc             


----------------------------------------------------------------------
End of Document                                                        
======================================================================
