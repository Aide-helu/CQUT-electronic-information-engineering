#include <stdio.h>
#include <string.h>
#define    N    80
void  fun(char  *w, int  m)
{



}
main()
{  char  a[N]= "ABCDEFGHIJK";
   int  m;
   printf("The original string:\n");puts(a);
   printf("\n\nEnter  m:  ");scanf("%d",&m);
   fun(a,m);
   printf("\nThe string after moving:\n");puts(a);
   printf("\n\n");
   NONO();
}
NONO()
{/* ���ڴ˺����ڴ��ļ�������������ݣ����� fun ������������ݣ��ر��ļ��� */
  FILE *rf, *wf ; char a[N] ; int m, i ;
  rf = fopen("bc180.in", "r") ;
  wf = fopen("bc180.out", "w") ;
  for(i = 0 ; i < 10 ; i++) {
    fscanf(rf, "%d %s", &m, a) ;
    fun(a, m) ;
    fprintf(wf, "%s\n", a) ;
  }
  fclose(rf) ; fclose(wf) ;
}

