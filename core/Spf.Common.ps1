function GetUsersFromCSV($CsvPath){
    $UserStrings = import-csv $CsvPath -header OrganizationUnit,LoginName -delimiter ';'
    $users = @();

    for($i=1;$i -le $UserStrings.Count;$i++)
    {
        $UserString = $UserStrings[$i];
        $users += $UserString;
        #Write-Host $UserString.LoginName `n
    }

    return $users
}

function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if($Invocation.PSScriptRoot)
    {
        $Invocation.PSScriptRoot;
    }
    Elseif($Invocation.MyCommand.Path)
    {
        Split-Path $Invocation.MyCommand.Path
    }
    else
    {
        $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
    }
}

function AddUpdateUsers($users){
    Import-Module ActiveDirectory

    foreach ($user in $users){
            $Puser = "";
            $Login = $user.Name;
            $DisplayName = $user.FirstName+' '+$user.LastName;
            $ManagerLogin = $user.Manager;
            $NUser = Get-ADUser -Filter "(sAMAccountName -eq '$Login')";
            if ($ManagerLogin.length){
                $Puser = Get-ADUser -Filter "(sAMAccountName -eq '$ManagerLogin')";
                if ($Puser -ne $Null){
                    $ManagerLogin = $Puser.distinguishedName;
                }
                
            }


            If ($NUser -eq $Null) {
                $NUser = New-ADUser -Name $DisplayName `
                    -Path  $user.Path `
                    -SamAccountName $Login `
                    -DisplayName $DisplayName `
                    -AccountPassword (ConvertTo-SecureString $user.Password -AsPlainText -Force) `
                    -ChangePasswordAtLogon $false `
                    -Enabled $true
                $NUser = Get-ADUser -Filter "(sAMAccountName -eq '$Login')";
            }

            $NUser.givenName = $user.FirstName;
            $NUser.sn = $user.LastName;
            $NUser.EmailAddress = $user.Email;
            $NUser.DisplayName = $DisplayName;
            $NUser.Company = $user.Company;
            $NUser.title = $user.JobTitle;
            $NUser.Department = $user.Department;
            
            
            $NUser.homePhone = $user.HomePhone;
            $NUser.physicalDeliveryOfficeName = $user.Office
            $NUser.telephoneNumber = $user.telephoneNumber;
            $NUser.facsimileTelephoneNumber = $user.Fax;
            $NUser.l = $user.City;
            $NUser.mobile = $user.MobilePhone;
            $NUser.msTSExpireDate3 = $user.Birthday;
            $NUser.msTSExpireDate4 = $user.WorkStarted;
            $NUser.pager = $user.InnerPhone;
            $NUser.streetAddress = $user.Address


            if ($ManagerLogin.length){
                $NUser.Manager = $ManagerLogin;
            }

            
            Set-ADUser -Instance $NUser;

            Write-Host $user.Name "Created Succesfully" -ForegroundColor Green
            
        }
}