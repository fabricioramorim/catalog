# Catalog

Organizando a facilidade.

## Sobre

O Catalog está sendo desenvolvido para apresentação no Inova CPS.

O intuito do aplicativo é ser desenvolvido utilizando as ferramentas do Google. Como linguagem estou utilizando Flutter e no banco de dados Firebase Database e Storage. O aplicativo também conta com o sistema de autenticação Firestore Authentication.

A necessidade que queremos sanar é a de catalogação de itens contidos em embalagens e organização dos mesmos sem a necessidade de abertura da embalagem em questão, ou seja, poderá ser descoberto o conteúdo sem a necessidade de manejos. Isso será feito com um QR Code ou Barcode fixado no exterior da embalagem, assim podendo ser escaneado na aplicação que exibirá seu conteúdo. Os QR Codes e Barcodes gerados poderão somente ser escaneados em um aplicativo Catalog e conta também com criptografia protegida por senha caso o conteúdo seja confidencial.

Caso haja a necessidade de alteração do conteúdo ou remoção de itens, isso poderá ser feito no aplicativo sem a necessidade de criação de um novo QR Code, pois eles contam com ID único global.

## Estrutura de dados

O sistema de autenticação atual conta com duas formas de registro e entrada, sendo e-mail e senha e também Google. A estrutura abaixo é de um usuário com as duas formas ativas que se mesclam automaticamente no Firebase Authentication assim reduzindo a chance de usuários duplicados. 

```JSON
{"users": [
{
  "localId": "ID_LOCAL",
  "email": "email@gmail.com",
  "emailVerified": true,
  "displayName": "Fabricio Amorim",
  "photoUrl": "URL_FOTO_DE_PERFIL",
  "lastSignedInAt": "1669754622129",
  "createdAt": "1667929188871",
  "providerUserInfo": [
    {
      "providerId": "google.com",
      "rawId": "ID_LOCAL",
      "email": "email@gmail.com",
      "displayName": "Fabricio Amorim",
      "photoUrl": "URL_FOTO_DE_PERFIL"
    }
  ]
}
]}
```

O cadastro de usuários por e-mail conta com verificação de endereço de e-mail no arquivo `/lib/access/verify_auth.dart` que envia um e-mail com o código de verificação através da utulização da função `sendEmailVerification()` do próprio `FirebaseAuth`.


A estrutura abaixo é gerada assim que criado um novo QR Code ou Barcode na aplicação. Ela é responsável por armazenar as informações e caminhos para arquivos e imagens anexados.

```JSON
{
    "ID_UNICO_DO_QR_CODE": {
      "cripto": "SENHA_QR_CODE_CRIPTOGRAFADA",
      "description": "Contem:\n\n1 teclado\n1 PC",
      "id": "ID",
      "storageRefFiles": [
        {
          "date": "2022-11-25 19:20:00.068436",
          "name": "IMG-20221125-WA0023.pdf",
          "ref": "URL_DO_ARQUIVO_NO_BUCKET"
        },
        {
          "date": "2022-11-25 19:20:08.100944",
          "name": "IMG-20221125-WA0024.pdf",
          "ref": "URL_DO_ARQUIVO_NO_BUCKET"
        }
      ],
      "storageRefImages": [
        {
          "date": "2022-11-25 19:18:28.890317",
          "name": "a38097ee-fef5-4aab-83ab-162ee60082463212782715081280763.jpg",
          "ref": "URL_DA_IMAGEM_NO_BUCKET",
          "uploadName": "file-2022-11-25 19:18:18.393960.jpg"
        }
      ],
      "title": "Teste 1",
      "user": "ID_DO_USUARIO_QUE_CRIOU",
      "user-mail": "EMAIL_DO_USUARIO_QUE_CRIOU"
    }
}}
```
