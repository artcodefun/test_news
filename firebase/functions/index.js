const https = require('https');
const admin = require('firebase-admin');
const functions = require("firebase-functions");

const { ResultStorage } = require('firebase-functions/lib/providers/testLab');
const { resolve } = require('path');

//const secret = require("./secret.json");
//admin.initializeApp({ credential: admin.credential.cert(secret), storageBucket: "test-news-39c24.appspot.com" });

admin.initializeApp();

const db = admin.firestore();
const fsNewsRef = db.collection("news");

const bucket = admin.storage().bucket();



const url = 'https://newsapi.org/v2/everything?' +
    'sortBy=publishedAt&' +
    'pageSize=10&' +
    'domains=bbc.co.uk,techcrunch.com,engadget.com&' +
    'language=en&' +
    'apiKey=d207de2ed47948ff9366b8eca6b4d8c8';


exports.updateFunction = functions.pubsub.schedule('every 10 minutes').onRun((context) => {
    updateNews();
    return null;
});

exports.makeUppercase = functions.firestore.document('/news/{documentId}')
    .onCreate((snap, context) => {

        const original = snap.get("title");

        const uppercase = original.toUpperCase();

        return snap.ref.set({ title: uppercase }, { merge: true });
    });


function updateNews() {



    let news = [];

    https.get(url, (resp) => {
        let data = '';

        resp.on('data', (chunk) => {
            data += chunk;
        });


        resp.on('end', async () => {
            let result = JSON.parse(data);
            news = result["articles"];

            if (!news) { console.error("news are unavailiable"); return; }

            let id = await getLastId();
            let doc = await getNewsDoc(id);
            let index = news.findIndex(e => ( e["description"] == doc.get("description")));

            console.log(`lastID: ${id}, index: ${index}, len: ${news.length}`);

            if (index == -1)
                addNews(news.reverse(), id + 1);
            else
                addNews(news.slice(0, index).reverse(), id + 1);

        });

    }).on("error", (err) => {
        console.log("Error: " + err.message);
    });

    return;

}



async function incrementID() {
    const info = await fsNewsRef.doc("info").set({ 'lastID': await getLastId() + 1 });

}

async function getLastId() {

    const info = await fsNewsRef.doc("info").get();
    return parseInt(info.get("lastID"), 10);

}

async function getNewsDoc(id) {
    const newsDoc = await fsNewsRef.doc(`${id}`).get();
    return newsDoc;

}

async function addNews(news, id) {

    for (let i = 0; i < news.length; i++) {

        let imageFile = bucket.file(`images/${id}.png`);

        try{
            await new Promise(function (resolve, reject) {

                https.get(news[i]["urlToImage"], function (res) {
                    res.pipe(imageFile.createWriteStream()).on("finish", ()=>{ resolve()});
                    //res.on("end", () => {console.log(`${id} okkkk 2`); resolve()});
                    res.on("error", (err) => {
                        console.log("Error: " + err.message);
                        reject(err);
                    });
                }).on("error", (err) => {
                    console.log("Error: " + err.message);
                    reject(err);
                });
    
            });
        }catch(err){
            console.log("Error: " + err.message);
            continue;
        }

        console.log(`${id} image !!!`);

        let newsDoc = fsNewsRef.doc(`${id}`);
        newsDoc.set({ title: news[i]["title"], description: news[i]["description"], image: `${id}.png` });

        await incrementID();


        id += 1;

    }
}