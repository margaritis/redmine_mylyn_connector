require File.dirname(__FILE__) + '/../test_helper'

class MylynConnector::IssuesControllerTest < MylynConnector::ControllerTest

  fixtures :users, :roles, :members, :issue_categories, :custom_fields, :trackers, :versions, :queries, :projects, :projects_trackers, :custom_fields_trackers, :issues, :journals, :attachments, :custom_fields, :custom_values, :watchers, :time_entries

  def setup
    super
    @controller = MylynConnector::IssuesController.new
  end

  def test_show_unauthenticated
    get :show, :id => 1
    assert_response :success
    assert_template 'show.xml.builder'

    xmldoc = XML::Document.string @response.body
    schema = read_schema 'issue'
    valid = xmldoc.validate_schema schema
    assert valid , 'Ergenis passt nicht zum Schema ' + 'issue'

    i = {:tag => 'issue', :attributes => {:id => 1, :editAllowed => false, :api => /^2.7.0/}}
    assert_tag i

#puts @response.body
    assert_tag :tag => 'subject', :content => 'Can\'t print recipes', :parent => i
    assert_tag :tag => 'description',:content => 'Unable to print recipes', :parent => i
    assert_tag :tag => 'createdon', :content => 3.days.ago.to_date.xmlschema, :parent => i
    assert_tag :tag => 'updatedon', :content => 1.days.ago.to_date.xmlschema, :parent => i

    assert_tag :tag => 'tracker', :content => '1', :parent => i
    assert_tag :tag => 'project', :content => '1', :parent => i
    assert_tag :tag => 'status', :content => '1', :parent => i
    assert_tag :tag => 'priority', :content => '4', :parent => i

    assert_tag :tag => 'watched', :content => 'false', :parent => i
    assert_tag :tag => 'watchers', :content => '', :parent => i

    assert_tag :tag=> 'startdate', :content => 1.day.ago.to_date.to_s, :parent => i
    assert_tag :tag=> 'duedate', :content => 10.day.from_now.to_date.to_s, :parent => i
    assert_tag :tag => 'doneratio', :content => '0', :parent => i
    assert_no_tag :tag=> 'estimatedhours', :parent => i

    assert_tag :tag => 'author', :content => '2', :parent => i
    assert_tag :tag => 'category', :content => '1', :parent => i
    assert_no_tag :tag => 'assignedto', :parent => i
    assert_no_tag :tag => 'fixedversion', :parent => i
    assert_no_tag :tag => 'parent', :parent => i

    assert_tag :tag => 'availablestatus', :content => '1', :parent => i

    cfs = {:tag => 'customvalues', :children => {:count => 3}, :parent => i}
    assert_tag :tag => 'customvalue', :attributes => {:customfieldid => 2}, :content => '125', :parent => cfs
    assert_tag :tag => 'customvalue', :attributes => {:customfieldid => 6}, :content => '2.1', :parent => cfs
    assert_tag :tag => 'customvalue', :attributes => {:customfieldid => 8}, :content => '2009-12-01', :parent => cfs

    jrns = {:tag => 'journals', :children => {:count => 2},:parent => i}
    jrn1 = {:tag => 'journal', :attributes => {:id => 1, :editablebyuser => 'false'}, :parent => jrns}
    assert_tag :tag => 'author', :content => '1', :parent => jrn1
    assert_tag :tag => 'notes', :content => 'Journal notes', :parent => jrn1
    assert_tag :tag => 'createdon', :content => 2.days.ago.to_date.xmlschema, :parent => jrn1
    jrn2 = {:tag => 'journal', :attributes => {:id => 2, :editablebyuser => 'false'}, :parent => jrns}
    assert_tag :tag => 'author', :content => '2', :parent => jrn2
    assert_tag :tag => 'notes', :content => 'Some notes with Redmine links: #2, r2.', :parent => jrn2
    assert_tag :tag => 'createdon', :content => 1.days.ago.to_date.xmlschema, :parent => jrn2

    assert_tag :tag => 'attachments', :children => {:count => 0}, :parent => i

    #TODO issuerelations

    tes = {:tag => 'timeentries', :children => {:count => 3}, :attributes => {:viewallowed => 'true', :newallowed => 'false'}, :parent => i}
    assert_tag :tag => 'sum', :content => '154.25', :parent => tes
    te1 = {:tag => 'timeentry', :attributes => {:id => 1, :editallowed => 'false'}, :parent => tes }
    assert_tag :tag => 'hours', :content => '4.25', :parent => te1
    assert_tag :tag => 'activity', :content => '9', :parent => te1
    assert_tag :tag => 'user', :content => '2', :parent => te1
    assert_tag :tag => 'spenton', :content => '2007-03-23', :parent => te1
    assert_tag :tag => 'comments', :content => 'My hours', :parent => te1
    assert_tag :tag => 'customvalues', :children => {:count => 0}, :parent => te1
    te2 = {:tag => 'timeentry', :attributes => {:id => 2, :editallowed => 'false'}, :parent => tes }
    assert_tag :tag => 'hours', :content => '150.0', :parent => te2
    assert_tag :tag => 'activity', :content => '9', :parent => te2
    assert_tag :tag => 'user', :content => '1', :parent => te2
    assert_tag :tag => 'spenton', :content => '2007-03-12', :parent => te2
    assert_tag :tag => 'comments', :content => '', :parent => te2
    assert_tag :tag => 'customvalue', :attributes => {:customfieldid => 8}, :content => '2009-12-01', :parent => {:tag => 'customvalues', :children => {:count => 1}, :parent => te2}

  end

#  def test_show_attachement
#    get :show, :id => 3
#    assert_response :success
#    assert_template 'show.rxml'
#
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issue'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issue'
#
#    assert_no_tag :tag => 'categoryid', :content => '1'
#    assert_no_tag :tag => 'fixedversionid'
#    assert_tag :tag => 'assignedtoid', :content => '3'
#    assert_tag :tag => 'attachments', :children => {:count => 4}
#    assert_tag :tag => 'author', :parent  => {:tag => 'attachment'}, :content => 'John Smith'
#    assert_tag :tag => 'contenttype', :parent  => {:tag => 'attachment'}, :content => 'text/plain'
#    assert_tag :tag => 'filename', :parent  => {:tag => 'attachment'}, :content => 'error281.txt'
#    assert_tag :tag => 'filesize', :parent  => {:tag => 'attachment'}, :content => '28'
#    assert_tag :tag => 'digest', :parent  => {:tag => 'attachment'}, :content => 'b91e08d0cf966d5c6ff411bd8c4cc3a2'
#    #issuerelations
#  end
#
#  def test_show_assigned
#    get :show, :id => 2
#    assert_response :success
#    assert_template 'show.rxml'
#
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issue'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issue'
#
#    assert_tag :tag => 'fixedversionid', :content => '2'
#    assert_tag :tag => 'assignedtoid', :content => '3'
#    #TODO test mit anmeldung als user #1, watched => true
#    assert_tag :tag => 'watched', :content => false
#    #redmine 0.8: 3
#    #redmine 0.9: 1 & 3
#    assert_tag :tag => 'watchers', :content => /(1 )?3/
#end
#
#  def test_show_404
#    get :show, :id => 99
#    assert_response 404
#  end
#
#  def test_query_by_id
#    get :query, :project_id => 1, :query_id => 1
#
#    assert_response :success
#    assert_template 'index.rxml'
#
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issues'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issues'
#
#    assert_tag :tag => 'issues', :children => {:count => 1}
#    assert_tag :tag => 'issue', :attributes => {:id => 3}
#  end
#
#  def test_query_by_string
#    post :query, :project_id => 1, :query_string => 'project_id=1&set_filter=1&fields[]=tracker_id&operators[tracker_id]=%3D&values[tracker_id][]=1&fields[]=category_id&operators[category_id]=!*&values[category_id][]=1'
#
#    assert_response :success
#    assert_template 'index.rxml'
#
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issues'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issues'
#
#    assert_tag :tag => 'issues', :children => {:count => 2}
#    assert_tag :tag => 'issue', :attributes => {:id => 3}
#    assert_tag :tag => 'issue', :attributes => {:id => 7}
#  end
#
#  def test_cross_query_by_string
#    post :query, :query_string => 'set_filter=1&fields[]=tracker_id&operators[tracker_id]=%3D&values[tracker_id][]=1&fields[]=priority_id&operators[priority_id]=%3D&values[priority_id][]=4'
#
#    assert_response :success
#    assert_template 'index.rxml'
#
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issues'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issues'
#
#    #redmine 0.8:
#    #redmine 0.9: 1,3,5,13
#    assert_tag :tag => 'issues', :children => {:count => 3..4}
#    assert_tag :tag => 'issue', :attributes => {:id => 1}
#    assert_tag :tag => 'issue', :attributes => {:id => 3}
#    assert_tag :tag => 'issue', :attributes => {:id => 5}
#    if is09?
#      assert_tag :tag => 'issue', :attributes => {:id => 13}
#    end
#  end
#
#  def test_cross_query_by_string_authenticated
#    @request.session[:user_id] = 2
#    post :query, :query_string => 'set_filter=1&fields[]=tracker_id&operators[tracker_id]=%3D&values[tracker_id][]=1&fields[]=priority_id&operators[priority_id]=%3D&values[priority_id][]=4'
#
#    assert_response :success
#    assert_template 'index.rxml'
#
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'issues'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'issues'
#
#    assert_tag :tag => 'issue', :attributes => {:id => 1}
#    assert_tag :tag => 'issue', :attributes => {:id => 3}
#    assert_tag :tag => 'issue', :attributes => {:id => 5}
#    assert_tag :tag => 'issue', :attributes => {:id => 4}
#    assert_tag :tag => 'issue', :attributes => {:id => 6}
#  end
#
#  def test_query_non_exists
#    get :query, :project_id => 1, :query_id => 99
#    assert_response 404
#  end
#
#  def test_updated_since
#    get :updated_since, :project_id => 1, :unixtime => 11.days.ago.to_i
#
#    assert_response :success
#    assert_template 'updated_since.rxml'
#
#    xmldoc = XML::Document.string @response.body
#    schema = read_schema 'updatedIssues'
#    valid = xmldoc.validate_schema schema
#    assert valid , 'Ergenis passt nicht zum Schema ' + 'updatedIssues'
#
#    #redmine 0.8: 1 & 7
#    #redmine 0.9: 1,7 & 8
#    assert_tag :tag => 'updatedissues', :content => /1 7( 8)?/
#  end

end
