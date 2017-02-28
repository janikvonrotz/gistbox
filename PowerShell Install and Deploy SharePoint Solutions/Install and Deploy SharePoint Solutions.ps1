Add-SPSolution -LiteralPath "E:\install\ChangePassword.wsp"

Install-SPSolution -Identity (Get-SPSolution | Where-Object{$_.Name -like "changepassword.wsp"}).SolutionId.Guid -GACDeployment