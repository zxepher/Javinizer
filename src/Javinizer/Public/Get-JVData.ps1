#Requires -PSEdition Core

function Get-JVData {
    [CmdletBinding(DefaultParameterSetName = 'Id')]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [String]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.r18')]
        [Boolean]$R18,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.r18zh')]
        [Boolean]$R18Zh,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javlibrary')]
        [Boolean]$Javlibrary,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javlibraryja')]
        [Boolean]$JavlibraryJa,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javlibraryzh')]
        [Boolean]$JavlibraryZh,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.dmm')]
        [Boolean]$Dmm,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javbus')]
        [Boolean]$Javbus,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javbusja')]
        [Boolean]$JavbusJa,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.javbuszh')]
        [Boolean]$JavbusZh,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('scraper.movie.jav321')]
        [Boolean]$Jav321,

        [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
        [Alias('javlibrary.baseurl')]
        [String]$JavlibraryBaseUrl = 'http://www.javlibrary.com',

        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'Id')]
        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'Url')]
        [PSObject]$Settings,

        [Parameter(ParameterSetName = 'Url')]
        [PSObject]$Url
    )

    process {
        $ProgressPreference = 'SilentlyContinue'
        $javinizerDataObject = @()
        $Id = $Id.ToUpper()

        if ($Url) {
            $urlObject = $Url | Get-JVUrlLocation
        } elseif ($Settings) {
            $R18 = $Settings.'scraper.movie.r18'
            $R18Zh = $Settings.'scraper.movie.r18zh'
            $Jav321 = $Settings.'scraper.movie.jav321'
            $Javlibrary = $Settings.'scraper.movie.javlibrary'
            $JavlibraryJa = $Settings.'scraper.movie.javlibraryja'
            $JavlibraryZh = $Settings.'scraper.movie.javlibraryzh'
            $Dmm = $Settings.'scraper.movie.dmm'
            $Javbus = $Settings.'scraper.movie.javbus'
            $JavbusJa = $Settings.'scraper.movie.javbusja'
            $JavbusZh = $Settings.'scraper.movie.javbuszh'
        }

        if ($Settings) {
            $JavlibraryBaseUrl = $Settings.'javlibrary.baseurl'
        }

        if ($JavlibraryBaseUrl[-1] -eq '/') {
            # Remove the trailing slash if it is included to create the valid searchUrl
            $JavlibraryBaseUrl = $JavlibraryBaseUrl[0..($JavlibraryBaseUrl.Length - 1)] -join ''
        }

        try {
            # You need to change this path if you're running the script from outside of the Javinizer module folder
            $jvModulePath = Join-Path -Path ((Get-Item $PSScriptRoot).Parent) -ChildPath 'Javinizer.psm1'

            foreach ($item in $urlObject) {
                Set-Variable -Name "$($item.Source)" -Value $true
                Set-Variable -Name "$($item.Source)Url" -Value $item.Url
            }

            if ($R18 -or $R18Zh) {
                $jvR18Url = Get-R18Url -Id $Id
                if ($R18) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - R18] [Url - $R18Url]"
                    Start-ThreadJob -Name "jvdata-R18" -ThrottleLimit 100 -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if ($using:R18Url) {
                            $using:R18Url | Get-R18Data
                        } else {
                            $jvR18Url = $using:jvR18Url
                            if ($jvR18Url) {
                                $jvR18Url.En | Get-R18Data
                            }
                        }
                    } | Out-Null

                }

                if ($R18Zh) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - R18Zh] [Url - $R18ZhUrl]"
                    Start-ThreadJob -Name "jvdata-R18Zh" -ThrottleLimit 100 -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if ($using:R18ZhUrl) {
                            $using:R18ZhUrl | Get-R18Data
                        } else {
                            $jvR18Url = $using:jvR18Url
                            if ($jvR18Url) {
                                $jvR18Url.Zh | Get-R18Data
                            }
                        }
                    } | Out-Null
                }
            }

            if ($Javlibrary -or $JavlibraryJa -or $JavlibraryZh) {
                $jvJavlibraryUrl = Get-JavlibraryUrl -Id $Id -BaseUrl $JavlibraryBaseUrl
                if ($Javlibrary) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Javlibrary] [Url - $JavlibraryUrl]"
                    Start-ThreadJob -Name "jvdata-Javlibrary" -ThrottleLimit 100 -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if ($using:JavlibraryUrl) {
                            $using:JavlibraryUrl | Get-JavlibraryData
                        } else {
                            $jvJavlibraryUrl = $using:jvJavlibraryUrl
                            if ($jvJavlibraryUrl) {
                                $jvJavlibraryUrl.En | Get-JavlibraryData
                            }
                        }
                    } | Out-Null
                }

                if ($JavlibraryJa) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavlibraryJa] [Url - $JavlibraryJaUrl]"
                    Start-ThreadJob -Name "jvdata-JavlibraryJa" -ThrottleLimit 100 -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if ($using:JavlibraryJaUrl) {
                            $using:JavlibraryJaUrl | Get-JavlibraryData
                        } else {
                            $jvJavlibraryUrl = $using:jvJavlibraryUrl
                            if ($jvJavlibraryUrl) {
                                $jvJavlibraryUrl.Ja | Get-JavlibraryData
                            }
                        }
                    } | Out-Null
                }

                if ($JavlibraryZh) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavlibraryZh] [Url - $JavlibraryZhUrl]"
                    Start-ThreadJob  -Name "jvdata-JavlibraryZh" -ThrottleLimit 100 -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if ($using:JavlibraryZhUrl) {
                            $using:JavlibraryZhUrl | Get-JavlibraryData
                        } else {
                            $jvJavlibraryUrl = $using:jvJavlibraryUrl
                            if ($jvJavlibraryUrl) {
                                $jvJavlibraryUrl.Zh | Get-JavlibraryData
                            }
                        }
                    } | Out-Null
                }
            }

            if ($Dmm) {
                $jvDmmUrl = Get-DmmUrl -Id $Id
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Dmm] [Url - $DmmUrl]"
                Start-ThreadJob  -Name "jvdata-Dmm" -ThrottleLimit 100 -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:DmmUrl) {
                        $using:DmmUrl | Get-DmmData
                    } else {
                        $using:jvDmmUrl | Get-DmmData
                    }
                } | Out-Null
            }

            if ($Javbus) {
                $jvJavbusUrl = Get-JavbusUrl -Id $Id
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Javbus] [Url - $JavbusUrl]"
                Start-ThreadJob  -Name "jvdata-Javbus" -ThrottleLimit 100 -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:JavbusUrl) {
                        $using:JavbusUrl | Get-JavbusData
                    } else {
                        $jvJavbusUrl = $using:jvJavbusUrl
                        if ($jvJavbusUrl) {
                            $jvJavbusUrl.En | Get-JavbusData
                        }
                    }
                } | Out-Null

                if ($JavbusJa) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavbusJa] [Url - $JavbusJaUrl]"
                    Start-ThreadJob  -Name "jvdata-JavbusJa" -ThrottleLimit 100 -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if ($using:JavbusJaUrl) {
                            $using:JavbusJaUrl | Get-JavbusData
                        } else {
                            $jvJavbusUrl = $using:jvJavbusUrl
                            if ($jvJavbusUrl) {
                                $jvJavbusUrl.Ja | Get-JavbusData
                            }
                        }
                    } | Out-Null
                }

                if ($JavbusZh) {
                    Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - JavbusZh] [Url - $JavbusZhUrl]"
                    Start-ThreadJob  -Name "jvdata-JavbusZh" -ThrottleLimit 100 -ScriptBlock {
                        Import-Module $using:jvModulePath
                        if ($using:JavbusZhUrl) {
                            $using:JavbusZhUrl | Get-JavbusData
                        } else {
                            $jvJavbusUrl = $using:jvJavbusUrl
                            if ($jvJavbusUrl) {
                                $jvJavbusUrl.Zh | Get-JavbusData
                            }
                        }
                    } | Out-Null
                }
            }

            if ($Jav321) {
                $jvJav321Url = Get-Jav321Url -Id $using:Id
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Search - Jav321] [$Url - $Jav321Url]"
                Start-ThreadJob  -Name "jvdata-Jav321" -ThrottleLimit 100 -ScriptBlock {
                    Import-Module $using:jvModulePath
                    if ($using:Jav321Url) {
                        $using:Jav321Url | Get-Jav321Data
                    } else {
                        $using:jvJav321Url | Get-Jav321Data
                    }
                } | Out-Null
            }

            $jobCount = (Get-Job | Where-Object { $_.Name -like 'jvdata-*' }).Count
            $jobId = @((Get-Job | Where-Object { $_.Name -like "jvdata-*" } | Select-Object Id).Id)
            $jobName = @((Get-Job | Where-Object { $_.Name -like "jvdata-*" } | Select-Object Name).Name)

            if ($jobCount -eq 0) {
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Warning -Message "[$Id] No scrapers were run"
                return
            } else {
                Write-Debug "[$Id] [$($MyInvocation.MyCommand.Name)] [Waiting - Scraper jobs] [$jobName]"
                # Wait-Job is used separately rather than in a pipeline due to the PowerShell.Exit job that is being created during the first-run of this function
                Wait-Job -Id $jobId | Out-Null

                Write-Debug "[$Id] [$($MyInvocation.MyCommand.Name)] [Completed - Scraper jobs] [$jobName]"
                $javinizerDataObject = Get-Job -Id $jobId | Receive-Job

                $hasData = ($javinizerDataObject | Select-Object Source).Source
                Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Success - Scraper jobs] [$hasData]"

                $dataObject = [PSCustomObject]@{
                    Data = $javinizerDataObject
                }

                if ($null -ne $javinizerDataObject) {
                    Write-Output $dataObject
                }
            }
        } catch {
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Error -Message "[$Id] [$($MyInvocation.MyCommand.Name)] Error occured during scraper jobs: $PSItem"
        } finally {
            # Remove all completed or running jobs before exiting this script
            # If jobs remain after closure, it may cause issues in concurrent runs
            Write-JVLog -Write:$script:JVLogWrite -LogPath $script:JVLogPath -WriteLevel $script:JVLogWriteLevel -Level Debug -Message "[$Id] [$($MyInvocation.MyCommand.Name)] [Removed - Scraper jobs]"
            Get-Job | Remove-Job -Force
        }
    }
}
