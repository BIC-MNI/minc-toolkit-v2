# -*- coding: utf-8 -*-
#
# Copyright 2016 Erik Bernhardsson
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import print_function
import argparse, git, datetime, numpy, pygments.lexers, traceback, time, os, fnmatch, json, progressbar
import pandas as pd


#import matplotlib
#matplotlib.use('Agg')
#from matplotlib import pyplot

# Some filetypes in Pygments are not necessarily computer code, but configuration/documentation. Let's not include those.
IGNORE_PYGMENTS_FILETYPES = ['*.json', '*.md', '*.ps', '*.eps', '*.txt', '*.xml', '*.xsl', '*.rss', '*.xslt', '*.xsd', '*.wsdl', '*.wsf', '*.yaml', '*.yml']


def analyze(repos, interval=7*24*60*60, ignore=[], only=[],branch=None,rename={},cohortfm='%Y',all_filetypes=False,prefix='.',earliest=None):
    default_filetypes = set()
    for _, _, filetypes, _ in pygments.lexers.get_all_lexers():
        default_filetypes.update(filetypes)
    default_filetypes.difference_update(IGNORE_PYGMENTS_FILETYPES)
    
    curves_set = set()
    curves = {}
    ts = []
    commit_history = {}
    master_commits = []
    code_commits = [] # only stores a subset
    commit2cohort = {}
    commit2timestamp = {}

    def rename_author(author):
        if author.email in rename:
            return rename[author.email]
        elif author.name in rename:
            return rename[author.name]
        else:
            return author.name
    
    repo = git.Repo(os.path.join(prefix,repos))
               
    print("Analyzing {}".format(repos))
    
    print('Listing all commits')
    bar = progressbar.ProgressBar(max_value=progressbar.UnknownLength)
    for i, commit in enumerate(repo.iter_commits(branch)):
        bar.update(i)
        cohort = datetime.datetime.utcfromtimestamp(commit.committed_date).strftime(cohortfm)
        curves_set.add(('cohort', cohort))
        curves_set.add(('author', rename_author(commit.author)))
        commit2cohort[commit.hexsha] = cohort
        
        if len(commit.parents) == 1:
            code_commits.append(commit)
            last_date = commit.committed_date
            commit2timestamp[commit.hexsha] = commit.committed_date
            
    bar.finish()
    
    print('Backtracking current branch')
    bar = progressbar.ProgressBar(max_value=progressbar.UnknownLength)
    i, commit = 0, repo.head.commit
    last_date = None
    while True:
        bar.update(i)
        if not commit.parents:
            break
        
        if last_date is None or commit.committed_date < last_date - interval:
            master_commits.append(commit)
            last_date = commit.committed_date
            
        if earliest is not None and commit.hexsha==earliest:
            break
        
        i, commit = i+1, commit.parents[0]

    bar.finish()
    
    print('Counting total entries to analyze + caching filenames')
    entries_total = 0
    bar = progressbar.ProgressBar(max_value=len(master_commits))
    
    ok_entry_paths = {} 
    def entry_path_ok(path):
        # All this matching is slow so let's cache it
        if path not in ok_entry_paths:
            ok_entry_paths[path] = (
                (all_filetypes or any(fnmatch.fnmatch(os.path.split(path)[-1], filetype) for filetype in default_filetypes))
                and all([fnmatch.fnmatch(path, pattern) for pattern in only])
                and not any([fnmatch.fnmatch(path, pattern) for pattern in ignore]))
        return ok_entry_paths[path]

    def get_entries(commit):
        return [entry for entry in commit.tree.traverse()
                if entry.type == 'blob' and entry_path_ok(entry.path)]
    
    for i, commit in enumerate(reversed(master_commits)):
        bar.update(i)
        n = 0
        for entry in get_entries(commit):
            n += 1
            _, ext = os.path.splitext(entry.path)
            curves_set.add(('ext', ext))
        entries_total += n
    bar.finish()
    
    def get_file_histogram(commit, path):
        h = {}
        try:
            for old_commit, lines in repo.blame(commit, path):
                cohort = commit2cohort.get(old_commit.hexsha, "MISSING")
                _, ext = os.path.splitext(path)
                
                keys = [('cohort', cohort), ('ext', ext), ('author', rename_author(old_commit.author))]

                if old_commit.hexsha in commit2timestamp:
                    keys.append(('sha', old_commit.hexsha))

                for key in keys:
                    h[key] = h.get(key, 0) + len(lines)
        except KeyboardInterrupt:
            raise
        except:
            traceback.print_exc()
        return h

    file_histograms = {}
    last_commit = None
    print('Analyzing commit history')
    bar = progressbar.ProgressBar(max_value=entries_total, widget_kwargs=dict(samples=10000))
    entries_processed = 0
    for commit in reversed(master_commits):
        t = datetime.datetime.utcfromtimestamp(commit.committed_date)
        ts.append(t)
        changed_files = set()
        for diff in commit.diff(last_commit):
            if diff.a_blob:
                changed_files.add(diff.a_blob.path)
            if diff.b_blob:
                changed_files.add(diff.b_blob.path)
        last_commit = commit

        histogram = {}
        entries = get_entries(commit)
        for entry in entries:
            bar.update(entries_processed)
            entries_processed += 1
            if entry.path in changed_files or entry.path not in file_histograms:
                file_histograms[entry.path] = get_file_histogram(commit, entry.path)
            for key, count in file_histograms[entry.path].items():
                histogram[key] = histogram.get(key, 0) + count

        for key, count in histogram.items():
            key_type, key_item = key
            if key_type == 'sha':
                commit_history.setdefault(key_item, []).append((commit.committed_date, count))

        for key in curves_set:
            curves.setdefault(key, []).append(histogram.get(key, 0))
    bar.finish()
    return curves, commit_history, curves_set, ts


if __name__ == '__main__':
    authors='identitites'
    outdir='.'
    
    repos=[
        'bic-pipelines','patch_morphology','xdisp','arguments','BEaST','bicgl',
        'Display','bicpl','classify','conglomerate', 
        'EBTKS','EZminc','glim_image','ILT','inormalize','libminc','minctools',
        'minc-widgets','mni_autoreg','mni-perllib','mrisim','N3','oobicpl',
        'postf', 'ray_trace','Register','.'
        ]
    #repos=['.','patch_morphology']
    repo_prefix='..'
    rename = {}
    interval= 7*24*60*60 # 1 week
    
    with open(authors,'r') as f:
        for ln in f:
            ll=ln.rstrip("\n").split('|')
            if len(ll)>1:
                for j in range(1,len(ll)):
                    rename[ll[j]]=ll[0]
            else:
                rename[ll[0]]=ll[0]
    
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    
    
    authors={}
    cohorts={}
    exts={}
    
    for r in repos :
        earliest=None
        if r=='minctools': earliest='cc7477c7e7bf46a45a1959a7030fd65863e79062' # don't analyze beyond that (libminc & minctools split)
        
        curves,commit_history,curves_set,ts=analyze(r,prefix=repo_prefix,rename=rename,interval=interval,earliest=earliest)
        
        def to_pandas(key_type, label_fmt=lambda x: x):
            key_items = sorted(k for t, k in curves_set if t == key_type)
            
            return {key_item:pd.Series(curves[(key_type, key_item)],index=ts,name=label_fmt(key_item)) for key_item in key_items}
            
        authors[r]=pd.DataFrame(to_pandas('author'))
        cohorts[r]=pd.DataFrame(to_pandas('cohort',lambda c: 'Year %s' % c))
        exts[r]=   pd.DataFrame(to_pandas('ext'))
    
    # resample to the same date range
    range_start=None
    range_end=None
    
    for k, a in authors.items():
        if range_start is None or range_start>a.index.min():range_start=a.index.min()
        if range_end   is None or   range_end<a.index.max():range_end  =a.index.max()
        
    print("Overall range:{} - {}".format(range_start,range_end))
    
    # FIX for broken time in some packages
    force_start=pd.Timestamp(1991,1,1)
    
    if range_start<force_start:
        range_start=force_start
    # resample by week
    rng = pd.date_range(start=range_start, end=range_end, freq='W')
        
    def pool_results(samples,rng):
        all_samples=set()
        # gather all keys
        for k, c in samples.items():
            all_samples.update(c.columns.tolist())
        all_samples = pd.DataFrame(columns=all_samples,index=rng).fillna(0.0)
        
        # resample all data 
        for k, c in samples.items():
            r=c.reindex(rng, method='ffill').fillna(0.0)
            # add columns
            for an in r.columns.tolist():
                all_samples[an]+=r[an]
        return all_samples
    
    
    # resampling by week
    # and join different authors into a single DataFrame
    all_authors = pool_results(authors,rng)
    all_cohorts = pool_results(cohorts,rng)
    all_exts    = pool_results(exts,rng)
    
    # save to HDF file
    store = pd.HDFStore('statistics.h5')
    store['all_authors']=all_authors
    store['all_cohorts']=all_cohorts
    store['all_exts']   =all_exts
    
    # save libminc authors
    store['libminc'] = authors['libminc']
    
    store.close()
    