% function [ Value,RowRelativeIndex,ColumnOffset ] = Matrix2CSC( Imatrix )
%% Matrix2CSC designed by Aki.
%% input a matrix,and output CRC arrays.use relative addressing,and output a zero when count 15 continuous zeros.
%% illustrated by examples
%% example 1
% 			Imatrix   =		  [111    98     5     0     0;
% 							   174     0     0     0     0;
% 								 0     1     0     6     0;
% 								 0     0     0     0     0;
% 								31    60     0     4     0;
% 								96    17     0     1     0;
% 								81     0     0     2     0;
% 							   188   221     0     3     0;
% 								 0     8     0     4     0;
% 								 0     0     0     5     0;
% 								 0     1     0     6     0;
% 								 0     0     0     8     0;
% 								 0     0     0     0     0;
% 								11     0     0     2     0;
% 								 0     0     0     6     0;
% 								 0     0     0     9     0;
% 								 0     0     0     1     0;
% 								11     0     0     4     0;
% 								23     0     0     2     0;
% 								59     0     0     5     0;
% 								 0     0     0     5     0;
% 								 0     0     0     0     1;
% 								 2     0     0     0     1;
% 							   111     0     0     0     0;
% 								 0     0     4     1     0;
% 								 4     0     0     3     0;
% 								66     0     0    90     0;
% 								71    21     3     0     0;
% 								 0     0     9     0     0;
% 								 1     0     0     3     0;
% 								 0     0     0     0     0;
% 								 0     4     2     0     5];
%% Value            = [111 174 31 96 81 188 11 11 23 59 2  111 4  66 71 1     98 1 60 17 221 8 1  0  21 4      5 0  4  3   9  2     6 4 1 2 3 4 5 6  8  2  6  9  1  4  2  5  5  1  3  90 3     0  1  1  5 ];
%% RowIndex         = [0   1   4  5  6   7  13 17 18 19 22 23  25 26 27 29    0  2 4  5  7   8 10 15 27 31     0 15 24 27  28 31    2 4 5 6 7 8 9 10 11 13 14 15 16 17 18 19 20 24 25 26 29   15 21 22 31];
%% RowRelativeIndex = [0,  1,  3, 1, 1,  1, 6, 4, 1, 1, 3, 1,  2, 1, 1, 2,    0, 2,2, 1, 2,  1,2, 5, 12,4,     0,15,9, 3,  1, 3,    2,2,1,1,1,1,1,1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 4, 1, 1, 3,   15,6, 1, 9];
%% ColumnOffset     = [0   16  26 32 53  57];%列偏移表示某一列的第一个元素在values里面的起始偏移位置。
%% end
%% example 2
% %                 Imatrix = [ 1 7 0 0;
% %                             0 2 8 0;
% %                             5 0 3 9;
% %                             0 6 0 4];
%% Value        = [1 5 7 2 6 8 3 9 4];//12 bit first
%% RowIndex     = [0 2 0 1 3 1 2 2 3];
%% RowRealtiveIndex = [0 2 0 1 2 1 1 2 1];//4 bit next
%% ColumnOffset = [0 2 5 7 9];//指针 12 

					 							 
    [RowNum,ColumnNum]      = size(Imatrix)         		;
    Num                     = RowNum    *  ColumnNum    	;%整个矩阵的大小
    CntZero                 = 0                     		;%对0计数
    CntCol                  = 0                     		;%列计数
    Value                   = 0                     		;%数值
    RowIndex                = 0                     		;%行索引
    ColumnOffset            = 0                     		;%列偏移
    j                       = 0                     		;
    k                       = 1                     		;
    m                       = 0                             ;
    n                       = 0                     		;				
for i = 1:Num		
    if 	Imatrix(i) ~= 0		
        n                   = n         +       1      		;%当输入的值是非0值时 存储该值 每个寄存器的index
        CntCol              = CntCol    +       1      		;%列计数 加1
        Value(n)            = Imatrix(i)            		;%保存此时的值
		RowIndex(n)         =                   m       ;%保存此时的行索引
		CntZero             = 			0	;%对0计数 复位0
	else	
		CntZero             = CntZero   +       1	;%当输入的值是0值时 不存储此时的值 以及行索引 并且0计数开始加1
		if CntZero	    ==   15	                            
		CntZero		    = 			0	;%当计数了连续15个0值时 对0计数复位
                CntCol              = CntCol    +       1      	;%列计数加1 因为要保存这个0值了
		n		    = n	     	+       1       ;
		Value(n)	    = 		0		;%保存0值
		RowIndex(n)	    =  		15		;%行索引直接是15
		end	
    end
		j                   = j      	+       1      	;
    if 	j == RowNum	
        j                   =                   0    	   	;% j是对一行的数据进行计数 
        k                   = k      	+       1      	   	;% k是列偏移的矩阵的索引
        ColumnOffset(k)     = CntCol 	+ ColumnOffset(k-1)	;% 列偏移是加上前一列非0数据的个数存入此时的矩阵中
        CntCol              =                   0           ;
    end
    if  m == (RowNum-1) %行索引 标志着是否该行数据全部被选择完成 当全部被访问后 复位0 否则继续上面的 访问
            m = 0;
    else
        m = m + 1;
    end
end

for ll = 1:ColumnNum
	ValidNum(ll) = ColumnOffset(ll+1) - ColumnOffset(ll);%这里是利用列偏移计算出一行有多少数据是非0值
end

index = 1;
for ll = 1:ColumnNum
	for kk = 1:ValidNum(ll)
		if kk == 1
			RowRelativeIndex(index) = RowIndex(index);%一列第一个行偏移是保存下来的
		else                                      
			RowRelativeIndex(index) = RowIndex(index) - RowIndex(index-1);%其余的行偏移都是相对于该列的第一个非0值的行偏移
		end
		index = index + 1;
	end
end



% end
    
