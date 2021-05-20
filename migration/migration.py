import firebase_admin
from firebase_admin import firestore


firebase_admin.initialize_app()

db = firestore.client()

newsRef = db.collection('news');
news= newsRef.get();

for key, value in news.items():
	if(not (key == "info") ):
		desc = value["description"]
		ref.child(key).update({"description":desc.lower()})
