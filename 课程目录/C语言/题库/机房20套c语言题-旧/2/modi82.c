#include <stdio.h>
/************found************/
fun(char a)
{   if(*a)
    {  fun(a+1)  ;
/************found************/
       printf("%c" *a);
    }
}

main()
{   char s[10]="abcd";
    printf("����ǰ�ַ���=%s\n������ַ���=",s);
    fun(s);printf("\n");
}
