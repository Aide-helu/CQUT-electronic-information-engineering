	.global start	; ����ȫ�ֱ��
    .mmregs
	.data
	.bss	x,1         ; ����ȫ�ֱ������ǳ�ʼ���Σ�
	.bss	y,1         ; ����������Ϊһ���֣�16λ��
	.bss	z,1

;���³������z=x+y
                .text
start:
                ST  #1, *(x)                       
;y=2(��Ĵ��룩
                 LD   *(x), A
                 ADD  *(y), A
                 STL   A, *(z)                                                                          
xh:	
	 B   xh                       ; ��ѭ��, �����ܷ�
	.end
	
