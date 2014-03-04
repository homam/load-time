USE Mobitrans;

WITH Visits AS (
	SELECT TOP 100000 
	V.Id AS visitId,
	V.Date_Created AS visitTime,
	W.RequestId AS submissionId,
	S.SubscriberId AS subscriberId,
	V.PageId AS pageId,
	V.Country AS countryId,
	V.RefId AS refId,
	webBrowser =
		CASE 
			WHEN (U.UA LIKE '%Windows NT%') THEN 1
			WHEN (SELECT COUNT(*) FROM dbo.FN_WURFL_FIND_Parents_By_Int_Wurfl_ID(U.Wurfl_Id) WHERE wurfl_device_id = 'generic_web_browser') = 1 THEN 1
			ELSE 0
		END 
	FROM dbo.Web_Visits V WITH (NOLOCK)
	INNER JOIN dbo.Wap_Visits_Ua U WITH (NOLOCK) ON V.UA_ID = U.UA_Id
	LEFT JOIN dbo.Web_Subscriptions W WITH (NOLOCK) ON W.VisitId = V.Id AND W.Source = 0
	LEFT JOIN dbo.Subscribers S WITH (NOLOCK) ON W.SubscriberId = S.SubscriberId
	WHERE V.PageId IN (494, 563, 526, 595)
	ORDER BY V.Id DESC
),

VisitsEvents AS (

	SELECT V.*, E.eventId, E.eventArgs, E.creationTime FROM Visits AS V
	Left JOIN dbo.MobiSpy_Events E WITH (NOLOCK) ON E.userId  = V.visitId
	-- 	WHERE V.WebBrowser = 1
)

SELECT C.ISO_Code AS country, P.Aspxfile as pageName, R.Referer AS referrer, E.* FROM VisitsEvents E
INNER JOIN dbo.Countries C WITH (NOLOCK) ON C.CountryId = E.countryId
INNER JOIN dbo.RefererValues R WITH (NOLOCK) ON R.Pk = E.refId
INNER JOIN dbo.PageValues P WITH (NOLOCK) ON P.Id = E.pageId
WHERE E.visitTime > '2014-03-03 17:00:00'
ORDER BY visitid desc