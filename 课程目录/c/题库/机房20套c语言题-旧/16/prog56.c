#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
int fun(int n)
{



}

main()   /*������*/
{   system("cls");
    printf("%d\n",fun(120));
    NONO();
}

NONO( )
{/* ���ڴ˺����ڴ��ļ�������������ݣ����� fun ������
    ������ݣ��ر��ļ��� */
   FILE  *wf;
   wf = fopen("a30.out", "w") ;
   fprintf(wf,"%d\n",fun(120));
   fclose(wf) ;
 }
