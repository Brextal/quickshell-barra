#!/bin/bash
curl -s "https://api.open-meteo.com/v1/forecast?latitude=-33.45&longitude=-70.66&daily=weathercode,temperature_2m_max&timezone=America/Santiago&forecast_days=14"
