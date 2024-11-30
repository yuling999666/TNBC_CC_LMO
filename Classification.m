clc
clear 
close all

%id=readtable('/Users/zhuyuling/Desktop/code/TNBC_CAP_mapping_spreadsheet_14Jan2023_final.xlsx');
id=readtable('/Users/zhuyuling/Desktop/TNBC/WHR.xlsx','ReadRowNames',true);
uid =id.capsession;
sz= length(uid);
cap_rt = uid;
 
s=zeros(5000,1);
a=0;
%opts = detectImportOptions('RAHBT_idMappingList_12July2022.xlsx');
%varNames = opts.VariableNames;
%varTypes = {'double','datetime','categorical','string'}; 
%opts = setvartype(opts,varNames,varTypes);     
%T=readtable('/Users/zhuyuling/Desktop/RAHBT_idMappingList_12July2022.xlsx',opts);
%path_num=T(:,4);
%sz_uid=size(path_num);
%path_num=table2array(path_num);
%x=sz_uid(1,1);
me=0;
wheels=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
names=["J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
dic=containers.Map(wheels,names);
pwd
current=pwd;
for i=1:sz
            z=0;
            %data_name=sprintf('%s%d','/data ',i);
            flag=0;
            folderPath2=strcat(current,'/',uid{i,1});
            %folderPath2=strcat(cap_rt{i});
            s(i)=exist(folderPath2,'dir');
            if s(i)==0%if the cap_session does not exist;
                fprintf(folderPath2);
                z=i+1;
                sc=sprintf('%s%d','B',z);
                hint='no_folder';
                %writematrix(hint,'/Users/zhuyuling/Downloads/filenamelist.xlsx','Sheet','sheet1','Range',sc);
            
            else %if the cap_session exists;
                cd(folderPath2);
                file_5=dir(folderPath2);
                 
                file_folder={file_5.folder};
               
                file_2={file_5.name};
                len=length(file_folder);
                total_folder={file_5.folder};
                pat=digitsPattern(1)+(".")+digitsPattern(1)+(".")+digitsPattern(3);
                a=a+1;
                start_1=0;%count how many images
                start_11=0;
                start_2=0;
                start_22=0;
                start_3=0;
                start_33=0;
                start_4=0;
                start_44=0;
                
                dir={file_5.isdir};
                folder4={file_5.folder};
                for j=1:len%read the images one by one;
                    flag=0;
                     
                    Fileaddress_1=strcat(folder4{j},'/',file_2{j});
                    %condi_2=startsWith(file_2{j},digitsPattern(1));
                    TF=endsWith(file_2{j},digitsPattern(5));
                    
                    %Fileaddress_1=strcat(file_2{j},'/DICOM');
                     
                    %s_1=exist(Fileaddress_1,'dir'); 
                    s_1=exist(file_folder{j},'dir'); 
                    if dir{j}==0
                        Fileaddress_1=strcat(folder4{j},'/',file_2{j});%find images's name
                        folder_name=strsplit(folder4{j},'/');
                        folder_len=length(folder_name);
                        file3name=folder_name{folder_len-1};
                        %% read the image when the path exists;
                         
                        try       
                                %% tell whether the image is broken
                        [X,map]=dicomread(Fileaddress_1);
                        catch ME
                            
                            fprintf(ME.message);
                            
                        end
                        if isempty(X)  
                           continue;
                        end 
                        size_x=size(X);
                        size_len=length(size_x);
                        
                        if size_len>2
                            if size_len==3
                                continue;
                            end
                            %document
                            z=i+1;
                            charac=strcat(uid{i,1},"/tomo/",file3name);
                            %find tomo
                            loc=dic(flag);
                            %sc=sprintf('%s%d',loc,z);
                            image=X(:,:,1,2);
                            %writematrix(charac,'/Users/zhuyuling/Downloads/filenamelist.xlsx','Sheet','sheet1','Range',sc);
                            MOVE=mat2gray(image);
                            [r,c]=size(MOVE); 
                             
                            flag=1;
                            
                        else
                                MOVE=mat2gray([X,map]);
                                [r,c]=size(MOVE);
                        end
                                %% tell whether it's a small image
                                if r<800 || c<800
                                    z=i+1;
                                    sc=sprintf('%s%d','R',z);
                                    Img=MOVE(r-90:r,[20,21,22]);%Select a small area in the lower left corner to tell whether it's right or left;
                                    condition_2=any(any(Img));
                                    if condition_2<1
                                        hint_1=strcat(uid{i,1},'small_images',file3name);
                                        writematrix(hint_1,'/Users/zhuyuling/Desktop/TNBC/WHR.xlsx','Sheet','sheet1','Range',sc);
                                         
                                    end
                                    continue;
                                end
                                %% tell whether it's a machine or petri dish;
                                con=all(MOVE,2);
                                con_1=any(con);
                                if con_1
                                    continue;
                                end
                                %% tell whether it's a machine or pieces;
                                
                                list_y=zeros(1,c);
                                for e=1:c
                                    non_zero_y=find(MOVE(:,e));
                                    if non_zero_y
                                        list_y(e)=non_zero_y(1);
                                    end
                                end
                                mo=mode(list_y);
                                
                                if mo>400
                                    continue
                                end
                                %% tell whether it's right or left;
                                Img=MOVE(r-200:r,[20,21,22]);%Select a small area in the lower left corner to tell whether it's right or left;
                                condition_2=any(any(Img));
                                %% tell mlo or cc;
                                row=floor(r/20);
                                Img_1=MOVE(1:row,:);
                                Img_2=reshape(Img_1,1,[]);
                                [N,edges]=histcounts(Img_2,[0,0.2,0.4,0.6,0.8,1]);
                                Img_bottom=MOVE(r-row,:);
                                Img_bottom_2=reshape(Img_bottom,1,[]);
                                [N_1,edges_1]=histcounts(Img_bottom_2,[0,0.2,0.4,0.6,0.8,1]);
                                %fprintf('%s %s will be %d this time.\n',folderPath2,fileaddress,N(1,3));
                                 
                                 
                                if condition_2<1 && (N(1,4)>=10000 || N(1,5)>=10000 || N(1,3)>=10000 || N_1(1,4)>=10000 || N_1(1,5)>=10000 || N_1(1,3)>=10000)%right mlo
                                     if flag==0
                                        start_1=start_1+1;
                                     
                                     elseif flag==1
                                      %tomo
                                     start_11=start_11+1;
                                     end
                                     z=i+1;
                                     name=file3name;
                                      
                                     if start_1==1 && flag==0
                                        sc=sprintf('%s%d','B',z);
                                       
                                     elseif start_1==2 && flag==0
                                        sc=sprintf('%s%d','C',z);
                                        
                                     elseif start_11==1 && flag==1
                                        sc=sprintf('%s%d','J',z);
                                        
                                     elseif start_11==2 && flag==1
                                         sc=sprintf('%s%d','K',z);
                                     end
                                     writematrix(name,'/Users/zhuyuling/Desktop/TNBC/WHR.xlsx','Sheet','sheet1','Range',sc);
                               
                                elseif condition_2 <1 && N(1,4)<10000 && N(1,5)<10000 && N(1,3)<10000 && N_1(1,4)<10000 && N_1(1,5)<10000 && N_1(1,3)<10000 %right CC
                                     if flag==0
                                        start_2=start_2+1;
                                     
                                     elseif flag==1
                                      %tomo
                                        start_22=start_22+1;
                                     end
                                     %name=strcat(cap_rt{i},'/',file_2{j});
                                     name=file3name;
                                      
                                     z=i+1;
                                     if start_2==1 && flag==0
                                        sc=sprintf('%s%d','D',z);
                                        
                                     elseif start_2==2 && flag==0
                                        sc=sprintf('%s%d','E',z);
                                     elseif start_22==1 && flag==1
                                        sc=sprintf('%s%d','L',z);
                                     elseif start_22==2 && flag==1
                                        sc=sprintf('%s%d','M',z);  
                                     end
                                      writematrix(name,'/Users/zhuyuling/Desktop/TNBC/WHR.xlsx','Sheet','sheet1','Range',sc);
                                elseif condition_2>=1 && (N(1,4)>=10000|| N(1,5)>=10000 || N(1,3)>=10000 || N_1(1,4)>=10000|| N_1(1,5)>=10000 || N_1(1,3)>=10000)%left mlo
                                     if flag==0
                                        start_3=start_3+1;
                                     
                                     elseif flag==1
                                      %tomo
                                        start_33=start_33+1;
                                     end
                                     z=i+1;
                                     name=file3name; 
                                     if start_3==1 && flag==0
                                        sc=sprintf('%s%d','F',z);
                                         
                                     elseif start_3==2 && flag==0
                                        sc=sprintf('%s%d','G',z);
                                     elseif start_33==1 && flag==1
                                         sc=sprintf('%s%d','N',z);
                                     elseif start_33==2 && flag==1
                                         sc=sprintf('%s%d','O',z);  
                                     end
                                     writematrix(name,'/Users/zhuyuling/Desktop/TNBC/WHR.xlsx','Sheet','sheet1','Range',sc);
                                elseif condition_2>=1 && N(1,4)<10000 && N(1,5)<10000 && N(1,3)<10000 && N_1(1,4)<10000 && N_1(1,5)<10000 && N_1(1,3)<10000%left CC
                                     if flag==0
                                        start_4=start_4+1;
                                     
                                     elseif flag==1
                                      %tomo
                                        start_44=start_44+1;
                                     end
                                     z=i+1;
                                     name=file3name; 
                                      
                                     
                                     if start_4==1 && flag==0
                                        sc=sprintf('%s%d','H',z);
                                        
                                     elseif start_4==2 && flag==0
                                        sc=sprintf('%s%d','I',z);
                                        
                                     elseif start_44==1 && flag==1
                                        sc=sprintf('%s%d','P',z);
                                     elseif start_44==2 && flag==1
                                        sc=sprintf('%s%d','Q',z);
                                     end
                                     writematrix(name,'/Users/zhuyuling/Desktop/TNBC/WHR.xlsx','Sheet','sheet1','Range',sc);
                                end
                    end
                 end
                         
                        cd('..')
                        cd('..')
                        cd('..')
                        cd('..')
                        cd('..')
                        cd('..')
                        cd('..')
            end 
end
                    
                
                 
                 %cd('..')
                 %cd('..')
                 cd('..')   
                 
           
           
 
 
      
         




               