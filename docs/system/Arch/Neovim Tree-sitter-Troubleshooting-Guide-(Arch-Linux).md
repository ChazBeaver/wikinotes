======================================================================
Neovim Tree-sitter Troubleshooting Guide (Arch Linux)                 
======================================================================


This guide documents how to diagnose and resolve Tree-sitter errors    
in Neovim caused by conflicting or stale parser binaries on Arch Linux.

The root cause addressed here is multiple Tree-sitter parser locations 
on the Neovim runtime path, where an older parser overrides the one     
managed by nvim-treesitter (Lazy.nvim).                                


----------------------------------------------------------------------
Symptoms                                                              
----------------------------------------------------------------------


One or more Tree-sitter features (usually highlighting) fail for a     
specific language (e.g., Python).                                      



Running :checkhealth nvim-treesitter shows an error similar to:         

  Invalid node type "except*"                                          

This indicates a mismatch between the Tree-sitter parser (.so) and     
the query files (.scm).                                                 


----------------------------------------------------------------------
Step 1: Identify Tree-sitter Health Errors                              
----------------------------------------------------------------------


Open Neovim and run the following command:                              
```
  :checkhealth nvim-treesitter                                         
```



What to look for:                                                      

- Any ❌ ERROR entries                                                  
- Language-specific errors (e.g., python(highlights))                  
- Messages mentioning "Invalid node type"                              
- Messages referencing query.lua or .scm files                         



If Tree-sitter is healthy, this section should show:                   

  nvim-treesitter: ✅                                                   

with no ERROR blocks at the bottom.                                    


----------------------------------------------------------------------
Step 2: Detect Multiple Installed Parsers                               
----------------------------------------------------------------------


The most common cause on Arch Linux is having multiple parser locations
on the runtime path. To see all parsers Neovim can find for a language,
run the following command inside Neovim:                               
```
  :lua print(vim.inspect(vim.api.nvim_get_runtime_file("parser/python.so", true)))
```



This command lists all python.so parser binaries visible to Neovim, in 
runtime resolution order (first entry wins).                           



Problem indication:                                                    

- More than one path is listed                                         
- A path under ~/.local/share/nvim/site/parser appears                 



Example problematic output:                                            

  ~/.local/share/nvim/site/parser/python.so                             
  ~/.local/share/nvim/lazy/nvim-treesitter/parser/python.so             



In this case, the site/ parser overrides the Lazy-managed parser and   
causes query incompatibility.                                          


----------------------------------------------------------------------
Step 3: Locate the Conflicting Parser Directory                         
----------------------------------------------------------------------


On Arch Linux, stale parsers often live in the following directory:    

  ~/.local/share/nvim/site/parser                                      



To inspect its contents from the shell:                                
```
  ls -la ~/.local/share/nvim/site/parser                               
```



If this directory contains many *.so files (bash.so, python.so, etc.), 
it indicates an old or external Tree-sitter installation.              


----------------------------------------------------------------------
Step 4: Safely Disable the Stale Parsers (Backup)                       
----------------------------------------------------------------------


Close Neovim completely before proceeding.                             



Instead of deleting the directory, move it to a timestamped backup to 
make the change reversible.                                            



Run the following command from the shell:                              
```
  mv ~/.local/share/nvim/site/parser ~/.local/share/nvim/site/parser.bak-2026-01-02
```



This removes the directory from Neovim’s runtime path while preserving
a backup for rollback if needed.                                       


----------------------------------------------------------------------
Step 5: Reinstall the Affected Parser via nvim-treesitter               
----------------------------------------------------------------------


Open Neovim again and run the following commands in order:             



Uninstall the existing Tree-sitter parser for the affected language:  
```
  :TSUninstall python                                                  
```



Reinstall the parser cleanly using nvim-treesitter:                    
```
  :TSInstall python                                                    
```



Ensure all installed parsers are updated and in sync:                 
```
  :TSUpdate                                                            
```


----------------------------------------------------------------------
Step 6: Verify Resolution                                               
----------------------------------------------------------------------


After reinstalling parsers, restart Neovim once more.                 



Run the Tree-sitter health check again:                                
```
  :checkhealth nvim-treesitter                                         
```



Verification criteria:                                                 

- The header shows:                                                    
    nvim-treesitter: ✅                                                 
- No ❌ ERROR blocks are present                                       
- The previously failing language (e.g., python) shows ✓ for highlights
- No "Invalid node type" errors remain                                



If these conditions are met, the issue is fully resolved.              


----------------------------------------------------------------------
Notes and Prevention                                                    
----------------------------------------------------------------------


Do NOT keep active Tree-sitter parsers in both of the following paths: 

- ~/.local/share/nvim/site/parser                                      
- ~/.local/share/nvim/lazy/nvim-treesitter/parser                      



Choose a single source of truth. When using Lazy.nvim, allow           
nvim-treesitter to fully manage parsers.                               



Keeping stale site/ parsers will eventually cause future breakage when
queries or grammars change.                                            


----------------------------------------------------------------------
Rollback (If Needed)                                                    
----------------------------------------------------------------------


To restore the previous state:                                         
```
  mv ~/.local/share/nvim/site/parser.bak-2026-01-02 ~/.local/share/nvim/site/parser
```



End of document                                                        
======================================================================
