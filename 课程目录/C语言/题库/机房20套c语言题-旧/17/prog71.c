#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#define M 100
void fun(int m,int *a,int *n)
{



}

main()
{   int aa[M],n,k;
    system("cls");
    fun(50,aa,&n);
    for(k=0;k<n;k++)
      if((k+1)%20==0) printf("\n");
      else printf("%4d",aa[k]);
    printf("\n");
   NONO( );
}

NONO ( )
{/* ���������ڴ��ļ����������ݣ����ú�����������ݣ��ر��ļ��� */
  FILE *fp, *wf ;
  int i, n, j, k, aa[M], sum ;

  fp = fopen("bs05.in","r") ;
  if(fp == NULL) {
    printf("�����ļ�bs05.in������!") ;
    return ;
  }
  wf = fopen("bs05.out","w") ;
  for(i = 0 ; i < 10 ; i++) {
    fscanf(fp, "%d,", &j) ;
    fun(j, aa, &n) ;
    sum = 0 ;
    for(k = 0 ; k < n ; k++) sum+=aa[k] ;
    fprintf(wf, "%d\n", sum) ;
  }
  fclose(fp) ;
  fclose(wf) ;
}


