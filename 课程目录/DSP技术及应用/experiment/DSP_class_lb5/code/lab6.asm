

      	.title "ex6.asm" 
   	
      	.def _c_int00
      	.mmregs
      	
      	.bss	a,3
      	.bss	b,3
      	.bss	c,1
      	.bss	d,1
      	.bss	e,1
      	.bss	x,1
      	
   	  	.data      	
table:  .word 2,3,4,5,7,9,6,8,10
	 
       	.text
_c_int00:                   
************���ݴ��ݣ�Ϊ����������a,b,c,d,e����ֵ************
           STM	#a,AR1
           RPT	?
           MVPD	?, ?
************������ۼӣ����Ϊ43h************           
           STM   #a,  AR2       ; AR2ָ��a�Ĵ洢��Ԫ�׵�ַ
           ??                ; AR3ָ��b�Ĵ洢��Ԫ�׵�ַ
           RPTZ  A, #2        
           ??               ;�ظ�ִ�г��ۼӲ������������A
           STL   A, *(x)         
************���������ǰ����������c ************           
           STM    #c,  AR4
           SUB     ?, ?
           STL      A, *(x)          
************����ӷ���ǰ����������d ************           
           STM  #d,  AR5
           ADD     ?, ?
           STL      A, *(x)      
************����˷���ǰ����������e ***********           
           LD	       *(x),  ?
           MPY      *(e), A
           STL         A, *(x) 
           
stop:      B		stop
          .end

