#include <conio.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
int fun(int s)
{


}

main()   /*������*/
{   int n;
    system("cls");
	n=1000;
    printf("n=%d,f=%d\n",n,fun(n));
   NONO();
}

NONO (  )
{/* ���������ڴ��ļ����������ݣ����ú�����������ݣ��ر��ļ��� */
  FILE *fp, *wf ;
  int i, n, s ;

  fp = fopen("ba06.in","r") ;
  if(fp == NULL) {
    printf("�����ļ�ba06.in������!") ;
    return ;
  }
  wf = fopen("ba06.out","w") ;
  for(i = 0 ; i < 10 ; i++) {
    fscanf(fp, "%d", &n) ;
    s = fun(n) ;
    fprintf(wf, "%d\n", s) ;
  }
  fclose(fp) ;
  fclose(wf) ;
}

