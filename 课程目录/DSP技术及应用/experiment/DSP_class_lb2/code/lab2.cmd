MEMORY
{
	PAGE 0:
		VECT : o=80h,l=80h
		PRAM : o=?,l=?	
	PAGE 1:                  
		DRAM : o=?,l=? 
}
SECTIONS
{
	/*����ζ����ڳ���ҳ*/
	.data   : {}> PRAM PAGE 0
	/*δ��ʼ���ζ���������ҳ*/
	.vectors: {}> VECT PAGE 0	
}
