# iMacloud-App 說明文件



撰寫人     :  minhaolee@itri.org.w 

文件版本 :  Ver 0.0.2 (2023.10.04) 



本 Repo 底下的專案相容於 iMacloud 專案 App 開發的 SOP

- 智慧機械雲   https://portal.imacloud.com.tw/
- 標準 Runtime 環境操作與開發手冊 (2022.06.30)
- iMacloud：2.19.5
- 地端引擎 imc-agent：12.1



# Ch1. IMM-ADX-Full ( Trial Mode : Offline )

本 Web 專案透過 Azure 數位孿生實現 OPC UA 和 Modbus 設備之間的通信，建立 OPC UA 和 Modbus 資料來源擴展，並與 Azure 數位孿生定義語言 (DTDL) 進行對應，可相容於 Azure  DTDL V2 版本與內建 Azure AD 資源整合作為 OAuth 2.0 + OpenId Connect (OIDC) 認證與授權平台。

https://github.com/Azure/opendigitaltwins-dtdl/tree/master/DTDL/v2。

本專案中使用的OPC UA 範例基於 Node-Red OPC UA 節點提供 Client 與 Server ; 但是您也可以採用其他任何 OPC UA CS 具有定義產業標準的資訊模型，例如 EUROMAP 77及EUROMAP 83標準，射出成型機 (Injection Moulding Machines, IMM) 與製造執行系統 (Manufacturing Execution System, MES) 之間資料交換的標準規範與此 App 進行串接 。該專案的目標是透過 Azure 數位孿生實現 OPC UA 和 Modbus 設備之間的通信，從而創建數位孿生及其相應模型。該專案將託管在 GitHub 上，以便於存取和協作。Azure Digital Twins建立 ITRI-ADX Blazor 專案架構圖如下。



<p align="center">
  <img src="./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-10-04_114259.png" alt="專案架構圖"><br>
  IMM-ADX-Full 專案架構圖
</p>



- 可創建一個數據源DataSource，例如 : OPC UA 和 Modbus。

- Azure 數字孿生定義語言 (DTDL)，進行Web交互式圖表的動態映射Mapping。

- IMM-ADX-Full 試用版 Trial 提供  2 hour 運行測試。 

- MockAPI 提供預先建立的 offline 離線版 Azure Digital Twins 的測試功能。

- 透過 IMM-ADX-Full.zip 封裝格式，將App上架至 iMacloud 智慧機械雲平台。

- IMM-ADX-Full 安裝 成為 iMaCloud App。

- 支援 Node-Red 快速整合 (提供內建 Modbus Master/Slave 與 OPCUA Client/Server 節點 Demo 範例)。

<p align="center">
  <img src="./IMM-ADX-Full/apps/IMM-ADX-Full/res/IMacloud.png" alt="IMacloud.png"><br>
  IMacloud App 安裝執行 IMM-ADX-Full 預設 https://localhost:8443 
</p>




## 1.1 IMM-ADX-Full 微服務網路架構圖

Docker Network 微服務網路架構圖

ex : IMM-ADX-Full  的 OPC UA Server模擬器於 Host 端  opc.tcp://127.0.0.1:5840 運行  (這是於  Node-Red 模擬出來的  OPC UA Server )

參考 Ch 3.2 入口網站 Node-Red 操作與說明，5840 在 Node-Red 其實是  host 5840 port 對應至內部 container 的 4840 port。

<p align="center">
  <img src="./IMM-ADX-Full/apps/IMM-ADX-Full/res/docker-compos.full.prod.png" alt="微服務網路架構圖"><br>
  微服務網路架構圖 入口網址為 https://localhost:8443 
</p>



## 1.2 docker-compose.full.yaml

以下為 Docker Network 設定的 Host Port Mapping 

可參考 https://github.com/mhlee0328/iMacloud-App/blob/main/IMM-ADX-Full/apps/IMM-ADX-Full/docker-compose.full.yaml

```yaml
version: '3.9'
# 1.For iMacloud App 機械雲1.4 射出機參數管理模版與微服務串接模組_Full 
# 2.Forked from docker-compose.prod.yaml. Users should be familiar with Azure ADT resource configurations
# 3.Trial version expires after a 2-hour timeout.

services:

  db:
    container_name: IMM-Full-db
    image: mhlee0328/imm-adx-full-mariadb:0.0.2-prod
    restart: unless-stopped
    environment:
      MARIADB_ROOT_PASSWORD: 123456
    volumes:
      - ./ContainerVolume/db:/var/lib/mysql
    ports:
      - 5806:3306
    networks:
      - IMM_Full_stack_nw
      

  node-red:
    container_name: IMM-Full-node-red
    image: mhlee0328/imm-adx-full-node-red:0.0.2-prod
    restart: unless-stopped
    ports:
      - 5880:1880
      - 5840:4840
      - 582:502
    volumes:
      - ./Simulators/NodeRed/data:/data
    networks:
      - IMM_Full_stack_nw




  api:
    container_name: IMM-Full-api
    image: mhlee0328/imm-adx-full-api:0.0.2-prod
    restart: unless-stopped
    environment:
      - ConnectionStrings__AdtLayoutDataBase=server=db;port=3306;database=adt_layout;user=root;password=123456
      - ASPNETCORE_URLS=https://+:443;http://+:80
      - ASPNETCORE_Kestrel__Certificates__Default__Password=123456
      - ASPNETCORE_Kestrel__Certificates__Default__Path=/https/aspnetapp.pfx
    volumes:
      - ./Certs/https:/https:ro
    networks:
      - IMM_Full_stack_nw



  web:
    container_name: IMM-Full-web
    image: mhlee0328/imm-adx-full-web:0.0.2-prod
    restart: unless-stopped
    ports:
      - 8880:80
      - 8443:443
    environment:
      # Azure AD 相關設定
      - AzureAd__Instance=https://login.microsoftonline.com/
      - AzureAd__Domain=mhlee0328hotmail.onmicrosoft.com
      - AzureAd__TenantId=51557692-759d-47e4-aee6-2b7f8321ab76
      - AzureAd__ClientId=460982e1-2ba0-425b-9f5d-452ec1cee957
      - AzureAd__ClientSecret=peQ8Q~kCTnZIHDHH93g4vSvBEruUVg63.J4cHb9i
      - AzureAd__CallbackPath=/signin-oidc
      - Queue__Host=queue
      - Queue__Port=5672
      - Queue__Username=admin
      - Queue__Password=admin
      - Queue__SensorQueueName=sensor
      - Queue__CommandQueueName=command
      - BackendUrl=https://api/
      - OfflineMode__Enabled=false
      - EnableFactorySimulator=false
      - ASPNETCORE_URLS=https://+:443;http://+:80
      - ASPNETCORE_Kestrel__Certificates__Default__Password=123456
      - ASPNETCORE_Kestrel__Certificates__Default__Path=/https/aspnetapp.pfx
    volumes:
      - ./Certs/https:/https:ro
    networks:
      - IMM_Full_stack_nw


networks:
  IMM_Full_stack_nw:
    driver: bridge
```



由以上 yaml 可以看到最關鍵的 Azure 資源存取有四個地方需要設定  

**必須**在 docker-compose.full.yaml 中定義以下環境變數：

- **AzureAd__Domain**   - 您自己的 Azure ADT 網域
- **AzureAd__TenantId** - 您自己的 Azure ADT 租用戶Id
- **AzureAd__ClientId**   - 您自己的 Azure ADT 用戶端 ID。可以透過 Azure 入口網站中的 Azure Active Directory -> 概述 -> 新增 -> 應用程式註冊下的 AAD 應用程式註冊來建立用戶端 ID
- **AzureAd__ClientSecret** - 您自己 Azure ADT 用戶端金鑰。可以在 AAD 應用程式註冊後在新增憑證或金鑰 -> 新用戶端金鑰下新增客戶端金鑰
- **AzureAd__CallbackPath=/signin-oidc**  -本專案指定採用  Azure AD 目錄服務，若要成功連線至 Azure 數位孿生服務實例，必須將上述 AAD 應用程式註冊指派給 Azure 數位孿生資料擁有者角色。並請參考 1.3 節 Azure AD 目錄服務設定要點 ! 



## 1.3 Azure AD 目錄服務

首先建立您自己的  Azure 資源群組及數位雙生必要項目，本專案使用了 Azure AD 目錄服務，因此我們直接納入 Azure AD 作為 OAuth 2.0 + OpenId Connect (OIDC) 認證與授權平台ODIC 是本專案重要的設定之一。

- 從 Azure AD 取得 `Application (client) ID`, `Directory (tenant) ID` 與 `Primary domain` , `secrets`這些重要參數，必須搭配本專案之 docker-compose.full.yaml 組態檔設定。


![](./IMM-ADX-Full/apps/IMM-ADX-Full/res/App Registration設定的畫面/2023-03-31_002606.png)



- OpenId Connect (OIDC) 設定，記得產生secrets key後，必須”先抄下secrets key”的value。

![2023-03-31_002645](./IMM-ADX-Full/apps/IMM-ADX-Full/res/App Registration設定的畫面/2023-03-31_002645.png)

- 這邊要依照您自己 Azure 的情況而定 SaaS PaaS 與 IaaS 各有不同，OpenId Connect (OIDC) 的 “ip 必須與部署的網址相同”
- 依照下圖進行設定，尤其是 Redirect URI 千萬別忘了，網址要先設定為 https://localhost:9001/signin-oidc


![2023-03-31_002827](./IMM-ADX-Full/apps/IMM-ADX-Full/res/App Registration設定的畫面/2023-03-31_002827.png)



- 建立好之後，記得要到 **Authentication** 頁籤勾選 `ID tokens` 核取項目， 將OpenId Connect (OIDC) 設定 tokens 進行勾選


![2023-03-31_002907](./IMM-ADX-Full/apps/IMM-ADX-Full/res/App Registration設定的畫面/2023-03-31_002907.png)





## 1.4 itridev_imm_adt_rg 設定參考畫面

使用 Azure 資源前，請先自學完 AZ-900基礎。

- https://learn.microsoft.com/zh-tw/training/courses/az-900t00  

Azure Digital Twins 文件，也是必要學習項目之一。

- https://learn.microsoft.com/zh-tw/azure/digital-twins/ 



提供簡要設定參考畫面，以"itridev_imm_adt_rg" 命名符合 Azure 命名慣例作為範例說明，並且也反映出 Resource Group 的用途和所屬領域，即針對 ITRI 開發的 Injection Molding Machine 應用進行開發和測試。

命名 Resource Group 時可以參考 Azure 建議的命名規則，命名慣例可以提高可讀性和管理性，有助於組織和管理 Azure 資源。Azure 建議的命名規則如下：

1. 名稱長度介於 1 到 90 個字元之間。
2. 可以使用字母、數字和連字號 (-)。
3. 名稱必須以字母或數字開頭和結尾。
4. 名稱中的字母必須是小寫。
5. 名稱中不允許使用特殊字元 (例如 @、#、$ 等)。

以提供的範例 "itridev-umati-adt-rg" 來說，長度在 90 個字元以內，使用了字母、數字和連字號，也符合以字母或數字開頭和結尾的慣例，建議將命名中的 "-" 改為 "_" 以符合命名慣例，例如 "itridev_umati_adt_rg"。

最後提醒的是，命名 Resource Group 時應盡量避免包含機密或敏感資訊，以保障安全性。若您的地點位於台灣，建議您在建立 Resource Group 時選擇 "East Asia" 作為 Location。因為 "East Asia" 是距離台灣較近的 Azure 區域，可以提供更好的連線速度和效能。另外，Azure 還提供其他亞洲區域，例如 "Southeast Asia" 和 "Japan East" 等，您也可以依據實際需求選擇適當的區域。



範例  "itri-imm-adt-001" 請抄錄您自己的Resource 重要的設定資訊，並替換 ch 1.2  節中提到的 docker-compose.yml 定義的環境變數

```powershell
## 修改為您自己的 Azure 資源

Resource group(move) : [itridev_imm_adt_rg](https://portal.azure.com/#@mhlee0328hotmail.onmicrosoft.com/resource/subscriptions/e0038f94-711b-4820-8415-ac34dbede1a3/resourceGroups/itridev_imm_adt_rg)

Host name : itri-imm-adt-001.api.sea.digitaltwins.azure.net
Subscription ID : e0038f94-711b-4820-8415-ac34dbede1a3
```

 

- Azure 於手機端 OTP核准或拒絕登入 MFA 驗證，搭配開啟 MFA 多重驗證於手機 App 安裝 OPT 認證，掃碼綁定後更容易使用 Azure 雲端多租戶的資源。

![2023-10-04_143235](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-10-04_143235.png)



- 範例  "itri-imm-adt-001" 重要的設定資訊

![2023-03-31_100634](./IMM-ADX-Full/apps/IMM-ADX-Full/res/itridev_imm_adt_rg 設定畫面/2023-03-31_100634.png)



- 範例  "itri-imm-adt-001" 重要的設定資訊 Access Control ( IAM )


![2023-03-31_102902](./IMM-ADX-Full/apps/IMM-ADX-Full/res/itridev_imm_adt_rg 設定畫面/2023-03-31_102902.png)



- 範例  "itri-imm-adt-001" 重要的設定資訊 Azure Digital Twins Explorer

![2023-03-31_102954](./IMM-ADX-Full/apps/IMM-ADX-Full/res/itridev_imm_adt_rg 設定畫面/2023-03-31_102954.png)



- 範例  "itri-imm-adt-001" 重要的設定資訊 Azure Digital Twins Explorer ( ADX ) Model上傳後畫面，數位雙生的DTDL model樣板，產生BasicInfo.json、CncController.json、Machine.json、Queue.json、Source.json等Base Model上傳至 Azure Digital Twins Explorer


![2023-03-31_103112](./IMM-ADX-Full/apps/IMM-ADX-Full/res/itridev_imm_adt_rg 設定畫面/2023-03-31_103112.png)



- 範例  "itri-imm-adt-001" 重要的設定資訊 Azure Digital Twins Explorer ( ADX ) Twins 模型設定，可自行依需求手動建立Twins或匯入已建立的Twins範例


![2023-03-31_103220](./IMM-ADX-Full/apps/IMM-ADX-Full/res/itridev_imm_adt_rg 設定畫面/2023-03-31_103220.png)



- 在 Azure Digital Twins Explorer 中的 DTDL V2模型，包含 Model & Twins的建立。實務上需要熟悉 Azure ADT 相關的雲端與數位孿生的技術，IMM-ADX-Full 先將 ADT 雲端服務建立相關的˙資源並運行。

![1](./IMM-ADX-Full/apps/IMM-ADX-Full/res/1.png)







# Ch2. IMM-ADX-Full 運行影片

- 可參考機械雲的影片 IMM ADX Full 容器執行使用說明

  https://www.youtube.com/playlist?list=PLEsqL3NnFN3CTIBm1lhkIhLcG-NqZFWAY

<iframe width="2244" height="935" src="https://www.youtube.com/embed/7qiDYDjcOxU" title="IMM ADX Full 容器執行使用說明" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>







# Ch3 . IMM-ADX-Full 容器執行使用說明

- 安裝 iMacloud 完成並啟動容器運行成功後，如果您是使用 Docker Desktop GUI 的介面，會看到 imm-adx-full 的 stack 底下有運行四個 IMM-Full 的微服務App，正在運行的狀態是否為 Running 


![2023-10-04_134659](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-10-04_134659.png)





## 3.1 本地端容器化入口網址

- 入口網址 https://localhost:8443/


![2023-08-01_164815](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_105527.png)

  

  

- 這裡我們使用 Host 電腦上的 OPC UA 模擬器 IMM_SimServer ( opc.tcp://localhost:6102)，因為 docker network 採取 bridge模式。小技巧提示，建議在此輸入將"localhost"替換為"host.docker.internal"。 如果您擁有其它對外設備的真實 ip ，您須指定該項服務的實際之 IP 與 Port 。


![2023-09-28_105713](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_105713.png)

  

- Azure 多租戶，依照您自己登入帳號的權限與資源群組，須指定 您自己 Azure 的 Subscription  。![2023-09-28_105756](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_105756.png)




- 須指定 您自己 Azure 的 Subscription  -> DigitalTwins。


![](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_105814.png)





- 須指定 您自己 Azure 的 Subscription  -> DigitalTwins -> DigitalTwins HostName。在此之前 ，您必須已經在 Azure ADT 建立好相關資源，並且上傳屬於您自己的 ADT Twins 與  Model， 請參考 Ch 1.4 說明。

![](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_110146.png)





## 3.2 入口網站 Node-Red 操作與說明

- 入口網址 https://localhost:8443/
- 這邊可以看到 IMM-Full-node-red 容器，本專案已預載 OPC UA Server 模擬器運行，您也可以自由更改 node-red 節點滿足您自己的需要，或是修改 ch 1.2 docker-compose.full.yaml 提到的 Docker File 進行微服務擴充與自由客製化調整。

![2023-09-28_110233](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_111410.png)



- SSO登入 node-red 模擬器 。


![2023-09-28_151043](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_151043.png)



- 添加 Datasource ，本專案已預載 OPC UA 與 Modbus TCP Ｄriver 。

![2023-09-28_151159](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_151159.png)



- Datasource 新刪修改 CRUD 功能， 提供不同資料來源的 Mapping 。

![2023-09-28_151209](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_151209.png)



- 除了 ＤigitalTwins提供不同資料來源的 Mapping 以外，Node 節點可以設定不同 style 上傳。OPC UA 即時資訊可以看到 DigitalTwins 的托退壓力的 Chart ，從 內建或外部設備 與OPC UA 服務，以 no-code 的˙方式進行映射資料來源組態設定。


![2023-09-28_151333](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_151333.png)



- Node 節點設定 Tag Mapping 。

![2023-09-28_151429](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_151429.png)





## 3.3 Node-Red  節點模擬結果


- Node-Red  節點模擬 OPC UA Server運行後
- 透過 UaExpert 的 OPC UA client 可由此下載 https://www.unified-automation.com/downloads/opc-ua-clients.html 。

![2023-09-28_145754](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_145754.png)

![2023-09-28_145817](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_145817.png)





- opc.tcp://127.0.0.1:5840

![2023-09-28_150958](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_150958.png)





- UaExpert 的 OPC UA client  範例畫面

![2023-09-28_150944](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_150944.png)



## 3.4  節點 Datasource  Mapping 操作說明


- Datasource mapping 提供匯入 CSV 及匯出 CSV。

  ![2023-10-04_105051](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-10-04_105051.png)

  

- Datasource mapping 提供匯入 CSV 及匯出 CSV。

  ![2023-10-04_105212](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-10-04_105212.png)

  

- Datasource mapping 提供 CRUD 功能

  ![2023-10-04_105234](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-10-04_105234.png)

  

- Datasource 提供 CSV  匯入/匯出功能
  
  ![2023-10-04_105321](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-10-04_105321.png)




- 執行一個您自己的OPC UA Server 資料來源 (例如 : IMM SimServer)。

  ![2023-07-30_232907](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-07-30_232907.png)

  

  

# Ch4 . IMM-ADX-Full 容器試用版執行

- IMM-ADX-Full Stack Trial Version 2 hour 倒數顯示

  ![2023-09-28_133900](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_133900.png)




- IMM-ADX-Full Stack Trial Version 2 hour 運行限制
  ![2023-09-28_133838](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-09-28_133838.png)

  

  
  
- 本專案 [iMacloud-App](https://github.com/mhlee0328/iMacloud-App#imacloud-app) 發布網址為 https://github.com/mhlee0328/iMacloud-App
- IMM-ADX-Full是一個Containers虛擬化環境，可以跨平台運作於 Linux、Windows作業系統，並且容器是輕量級的,讓可以動態建立/擴展/停止。因此可被部署於地端或雲端執行。
  - 本地端localhost已支持docker-compose 的環境中
  - Azure IaaS  如 VM 的環境中
  - Azure PaaS 如 Azure Container Instances, ACI 。AppService需開啟相關設定，另外本專案有開啟 ContainerVolume ，因此Azure container instance file share Storage 需要事先完成相關設定
  - Azure SaaS 如 K8S 的環境中

![2023-10-04_150713](./IMM-ADX-Full/apps/IMM-ADX-Full/res/2023-10-04_150713.png)

使用方式相容於所有 Docker-enabled 的環境

開始執行指令為 : 

```powershell
## 如果您是 Win11 Preview 最高階版本
## $env:DOCKER_HOST="tcp://localhost:2375"

docker-compose -f .\docker-compose.full.yaml up
```

結束執行指令為 : 

```powershell
docker-compose -f .\docker-compose.full.yaml down
```

